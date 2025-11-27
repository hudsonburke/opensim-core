#
# OpenSim Top-Level Build Script
#
cmake_minimum_required(VERSION 3.15)
project(OpenSim)

# Set modern CMake policies.
cmake_policy(SET CMP0003 NEW)
cmake_policy(SET CMP0005 NEW)
cmake_policy(SET CMP0048 NEW) # Required for CXX standard versioning.
cmake_policy(SET CMP0067 NEW) # Honor INTERFACE_COMPILE_DEFINITIONS

message(STATUS "NOTICE: Make sure all OpenSim dependencies are built with the \
same CMAKE_BUILD_TYPE (Linux) or CONFIGURATION (Xcode/MSVC) as OpenSim to \
avoid mysterious runtime errors.")

# Use folder hierarchy in IDEs like Visual Studio.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# Configure project versioning (e.g., from Git).
include(cmake/OpenSimVersioning.cmake)

# Include custom macros and feature summary tool.
set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
include(OpenSimMacros)
include(FeatureSummary)

# Configure the installation directory prefix.
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  # On Windows, override the default to avoid permissions issues with Program Files.
  # On Linux, override the default as our layout may not be FHS-compliant.
  set(CMAKE_INSTALL_PREFIX "${CMAKE_SOURCE_DIR}-install" CACHE PATH
        "The directory in which to install this project." FORCE)
endif()

# Set C++ standard. This is not optional.
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- Build Options ---

# Specify number of cores to run tests.
include(ProcessorCount)
ProcessorCount(PROCESSOR_COUNT)
set(PROCESSOR_COUNT "${PROCESSOR_COUNT}" CACHE STRING
    "Number of concurrent jobs when running tests via RUN_TESTS_PARALLEL target.")
mark_as_advanced(PROCESSOR_COUNT)

option(OPENSIM_DOXYGEN_USE_MATHJAX "Use MathJax for Doxygen equations." ON)

option(OPENSIM_PYTHON_STANDALONE "Make the Python package standalone, copying shared libraries into the package." OFF)
mark_as_advanced(OPENSIM_PYTHON_STANDALONE)

option(OPENSIM_PYTHON_CONDA "Build specifically for Conda packaging." OFF)
mark_as_advanced(OPENSIM_PYTHON_CONDA)

option(BUILD_API_ONLY "Build/install only headers, libraries, wrapping, tests; not applications." OFF)

option(OPENSIM_DISABLE_LOG_FILE "Disable the automatic 'opensim.log' file." OFF)

option(OPENSIM_DISABLE_STATIC_TYPE_REGISTRATION "Disable static registration of Object types." OFF)
mark_as_advanced(OPENSIM_DISABLE_STATIC_TYPE_REGISTRATION)

set(OPENSIM_BUILD_INDIVIDUAL_APPS_DEFAULT OFF)
if(WIN32)
  set(OPENSIM_BUILD_INDIVIDUAL_APPS_DEFAULT ON) # Backwards compatibility for Windows dist.
endif()
option(OPENSIM_BUILD_INDIVIDUAL_APPS
    "Build/install the old command line applications (ik, id, rra, etc.)."
    ${OPENSIM_BUILD_INDIVIDUAL_APPS_DEFAULT})
mark_as_advanced(OPENSIM_BUILD_INDIVIDUAL_APPS)

# Moco options.
option(OPENSIM_WITH_CASADI "Build CasADi support for Moco (MocoCasADiSolver)." ON)
add_feature_info(WITH_CASADI OPENSIM_WITH_CASADI "Build CasADi support for Moco")

# Bindings options.
option(BUILD_JAVA_WRAPPING "Build Java wrapping (requires SWIG and Java)." OFF)
option(BUILD_PYTHON_WRAPPING "Build Python wrapping (requires SWIG and Python)." OFF)
set(OPENSIM_PYTHON_VERSION 3)


# --- Platform and Compiler Setup ---

# Set a default build type if none is specified (e.g., for Makefiles).
if(NOT MSVC AND NOT XCODE AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the build type." FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Add basic, cross-platform warnings.
# The previous manual flag management was brittle. Modern CMake and compilers
# do a better job. We only add essential warnings.
add_compile_options(-Wall -Wextra)
# Avoid warnings for Object::Self and Object::Super typedefs.
if (${CMAKE_CXX_COMPILER_ID} MATCHES "GNU" OR
    (${CMAKE_CXX_COMPILER_ID} MATCHES "Clang" AND NOT CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.0))
  add_compile_options(-Wno-unused-local-typedefs)
endif()

# Suppress "unused variable" warnings in release builds where assert() is compiled out.
add_compile_options($<$<NOT:$<CONFIG:Debug>>:-Wno-unused-variable>)
add_compile_options($<$<NOT:$<CONFIG:Debug>>:-Wno-unused-parameter>)

# On Windows, disable specific warnings.
if(WIN32)
  add_definitions(-D_CRT_SECURE_NO_DEPRECATE)
  add_compile_options(/wd4068) # unknown pragma
endif()

# Set library postfix for debug builds (e.g., "_d").
if(WIN32)
  set(CMAKE_DEBUG_POSTFIX "_d" CACHE INTERNAL "" FORCE)
else()
  set(CMAKE_DEBUG_POSTFIX "_d" CACHE STRING "Suffix for debug libraries")
endif()


# --- Dependency Discovery (vcpkg) ---

# All dependencies are now found via the vcpkg toolchain file.

option(OPENSIM_C3D_PARSER "C3D file parser selection" "ezc3d")
set_property(CACHE OPENSIM_C3D_PARSER PROPERTY STRINGS "ezc3d" "None")
if(${OPENSIM_C3D_PARSER} STREQUAL "ezc3d")
  find_package(ezc3d REQUIRED)
  set(WITH_EZC3D TRUE)
  # This global definition is still required by some parts of the code.
  add_definitions(-DWITH_EZC3D)
else()
  set(WITH_EZC3D FALSE)
endif()

find_package(spdlog REQUIRED)
find_package(Simbody 3.7 REQUIRED)
if(OPENSIM_WITH_CASADI)
  find_package(casadi 3.6.5 REQUIRED)
  find_package(Ipopt REQUIRED)
  set_package_properties(casadi PROPERTIES TYPE REQUIRED PURPOSE "Differentiation and optimizer interface.")
endif()

# This global include should be removed eventually, but some parts of the build
# may still rely on it.
include_directories("${Simbody_INCLUDE_DIR}")


# --- Configure Installation and Build ---

# Set up the installation directory layout (e.g., FHS vs. custom).
include(cmake/OpenSimInstallLayout.cmake)

# Find MATLAB if Java wrapping is enabled.
if(BUILD_JAVA_WRAPPING)
  find_package(Matlab COMPONENTS MAIN_PROGRAM)
endif()

# Add preprocessor definitions for versioning.
add_definitions(
    -DOSIM_SYS_INFO=${CMAKE_SYSTEM}
    -DOSIM_COMPILER_INFO=${CMAKE_CXX_COMPILER}
    -DOSIM_OS_NAME=${CMAKE_SYSTEM_NAME}
    -DOSIM_VERSION=${OPENSIM_QUALIFIED_VERSION}
)
if(OPENSIM_DISABLE_LOG_FILE)
  add_definitions(-DOPENSIM_DISABLE_LOG_FILE=1)
endif()
if(OPENSIM_DISABLE_STATIC_TYPE_REGISTRATION)
  add_definitions(-DOPENSIM_DISABLE_STATIC_TYPE_REGISTRATION=1)
endif()


# --- Testing Setup ---
enable_testing()
include(CTest)

# Create a custom target to run tests in parallel.
if(MSVC OR XCODE)
  set(OPENSIM_TEST_BUILD_CONFIG --build-config ${CMAKE_CFG_INTDIR})
endif()
add_custom_target(RUN_TESTS_PARALLEL
    COMMAND ${CMAKE_CTEST_COMMAND} --parallel ${PROCESSOR_COUNT}
                                   ${OPENSIM_TEST_BUILD_CONFIG}
                                   --output-on-failure
)


# --- Build Targets ---

# This directory contains files (e.g., .osim) that multiple tests may use.
set(OPENSIM_SHARED_TEST_FILES_DIR "${CMAKE_SOURCE_DIR}/OpenSim/Tests/shared")

add_subdirectory(Vendors)
add_subdirectory(OpenSim)
if(NOT BUILD_API_ONLY)
  add_subdirectory(Applications)
endif()
add_subdirectory(Bindings)
add_subdirectory(cmake)
add_subdirectory(doc)


# --- Finalization ---

# Create buildinfo.txt file for troubleshooting.
set(VERSION_FILE_PATH ${CMAKE_BINARY_DIR}/OpenSim_buildinfo.txt)
file(WRITE ${VERSION_FILE_PATH} "Product Version=${OPENSIM_RELEASE_VERSION}\n")
file(APPEND ${VERSION_FILE_PATH} "Compiler=${CMAKE_GENERATOR}-${CMAKE_CXX_COMPILER_ID}\n")
file(APPEND ${VERSION_FILE_PATH} "Platform=${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}\n")
install(FILES ${VERSION_FILE_PATH} DESTINATION "${CMAKE_INSTALL_SYSCONFDIR}")

# Print a summary of build features and dependencies.
feature_summary(WHAT ALL)
