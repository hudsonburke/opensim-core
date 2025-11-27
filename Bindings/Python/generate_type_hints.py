import sys
import os
import re
import subprocess
from clang.cindex import Index, TranslationUnit, CursorKind

def get_system_include_paths():
    """
    Finds system C++ include paths by querying clang. This makes the script
    portable and not dependent on hardcoded paths.
    """
    try:
        process = subprocess.run(
            ['clang', '-v', '-E', '-x', 'c++', '-'],
            input='',
            capture_output=True,
            text=True,
            encoding='utf-8',
            errors='ignore'
        )
        output = process.stderr
    except FileNotFoundError:
        print(
            "Error: 'clang' command not found. Please ensure clang is installed "
            "and in your PATH.",
            file=sys.stderr
        )
        return []

    paths = []
    search_path_section = re.search(
        r'#include <\.\.\.> search starts here:\n(.*?)\nEnd of search list.',
        output,
        re.DOTALL
    )

    if search_path_section:
        paths_str = search_path_section.group(1)
        for line in paths_str.split('\n'):
            path = line.strip()
            if path and os.path.exists(path):
                paths.append(path)

    try:
        process = subprocess.run(
            ['clang', '-print-resource-dir'],
            capture_output=True, text=True, check=True
        )
        resource_dir = process.stdout.strip()
        if resource_dir:
            clang_include_path = os.path.join(resource_dir, 'include')
            if os.path.exists(clang_include_path):
                paths.append(clang_include_path)
    except (FileNotFoundError, subprocess.CalledProcessError):
        pass

    return list(set(paths))

def map_type(type_obj):
    """Maps a Clang Type object to a Python type hint string."""
    type_str = type_obj.spelling.replace(' &', '').replace(' *', '')
    type_str = type_str.replace('::', '.')

    if 'bool' in type_str: return 'bool'
    if 'int' in type_str: return 'int'
    if 'double' in type_str: return 'float'
    if 'void' in type_str: return 'None'
    if 'string' in type_str: return 'str'

    if '.' in type_str or type_str.startswith('OpenSim') or type_str.startswith('SimTK'):
        return f'\'{type_str}\''

    return 'Any'

def main():
    """
    Parses an OpenSim C++ header and generates a .pyi stub file for it.
    """
    # --- Configuration ---
    header_path = 'OpenSim/Simulation/Model/Model.h'
    output_pyi_path = 'Bindings/Python/opensim/simulation.pyi'
    target_class_name = 'OpenSim::Model'
    project_root = os.path.abspath('.')
    simbody_include = os.path.abspath(
        os.path.join(project_root, '../opensim_dependencies_install/simbody/include')
    )

    # --- Pre-flight Check ---
    if not os.path.isdir(simbody_include):
        print(
            f"Error: The simbody include directory was not found at the expected path.\n"
            f"Checked path: {simbody_include}\n\n"
            "Please ensure you have downloaded and built the OpenSim "
            "dependencies by running the CMake superbuild, which is often found in "
            "a 'dependencies' directory.",
            file=sys.stderr
        )
        sys.exit(1)

    # --- Automatic Include Path Detection ---
    print("Automatically detecting system include paths...")
    system_paths = get_system_include_paths()
    if not system_paths:
        print(
            "Warning: Could not automatically determine system include paths. "
            "Stub generation may fail.",
            file=sys.stderr
        )
    else:
        print(f"Found {len(system_paths)} system include paths.")

    # --- Path Combination ---
    include_paths = [project_root, simbody_include]
    all_include_paths = list(set(include_paths + system_paths))
    clang_args = [f'-I{path}' for path in all_include_paths]
    clang_args.append('-std=c++11')

    # --- Parsing ---
    print(f"Parsing C++ header: {header_path}")
    index = Index.create()
    try:
        tu = index.parse(
            header_path,
            args=clang_args,
            options=TranslationUnit.PARSE_SKIP_FUNCTION_BODIES
        )
        if not tu:
            raise RuntimeError("Unable to parse Translation Unit. This often happens if a required include path is missing.")

        # Check for parsing errors
        has_errors = False
        for diag in tu.diagnostics:
            if diag.severity >= diag.Error:
                print(f"Clang Error: {diag.spelling}", file=sys.stderr)
                has_errors = True
        if has_errors:
            print(
                "\nError: Clang failed to parse the header. Please check the errors above.",
                file=sys.stderr
            )
            sys.exit(1)

    except Exception as e:
        print(f"An unexpected error occurred during parsing: {e}", file=sys.stderr)
        sys.exit(1)

    # --- .pyi Content Generation ---
    pyi_content = ['from typing import Any', '']
    
    print(f"Searching for class: {target_class_name}")
    found_class = False
    for cursor in tu.cursor.walk_preorder():
        if (
            cursor.kind == CursorKind.CLASS_DECL and
            cursor.spelling == target_class_name.split('::')[-1] and
            cursor.is_definition() and
            cursor.displayname == target_class_name
        ):
            
            found_class = True
            class_name = cursor.spelling
            pyi_content.append(f'class {class_name}:')

            for method in cursor.get_children():
                if (
                    method.kind == CursorKind.CXX_METHOD and
                    method.access_specifier == clang.cindex.AccessSpecifier.PUBLIC and
                    not method.spelling.startswith('~') and
                    not method.is_constructor()
                ):

                    method_name = method.spelling
                    return_type = map_type(method.result_type)
                    
                    params = ['self']
                    for arg in method.get_arguments():
                        param_name = arg.spelling or 'arg'
                        param_type = map_type(arg.type)
                        params.append(f'{param_name}: {param_type}')
                    
                    pyi_content.append(f'    def {method_name}({', '.join(params)}) -> {return_type}: ...')
            break

    if not found_class:
        print(f"Error: Could not find class '{target_class_name}' in the header.", file=sys.stderr)
        sys.exit(1)

    # --- Write .pyi File ---
    os.makedirs(os.path.dirname(output_pyi_path), exist_ok=True)
    with open(output_pyi_path, 'w') as f:
        f.write('\n'.join(pyi_content))

    print(f"\nSuccessfully generated type hints at: {output_pyi_path}")

if __name__ == "__main__":
    main()