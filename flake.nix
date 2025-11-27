{
  description = "A development environment for OpenSim";

  # Nix Flakes are a new feature and require this input to be specified.
  # This tells Nix where to get the standard library of packages.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Pin to a stable version for reproducibility

  # This is the main part of the flake, defining what it provides.
  outputs = { self, nixpkgs }:
    let
      # We'll support Linux and macOS.
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];

      # A helper function to generate the environment for each system.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # The actual package set for a given system.
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      # The 'devShells' attribute defines development environments.
      # `nix develop` will activate this shell.
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system; in
        {
          default = pkgs.mkShell {
            # List all system-level dependencies required to build the project.
            # Nix will make these available in the environment.
            packages = [
              # Core build tools
              pkgs.cmake
              pkgs.gnumake
              pkgs.gcc # On macOS, this will alias to clang

              # Language and binding generators
              pkgs.swig
              pkgs.python3

              # OpenSim requires a specific Java version (e.g., 11)
              pkgs.openjdk11

              # vcpkg is needed to manage C++ library dependencies
              pkgs.vcpkg
            ];

            # You can also set environment variables if needed.
            # For example, to help vcpkg find the right JDK.
            shellHook = ''
              export JAVA_HOME="${pkgs.openjdk11}"
            '';
          };
        });
    };
}
