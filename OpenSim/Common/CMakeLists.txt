# Define the library name.
set(OSIM_LIB_NAME osimCommon)

# Gather source and header files.
file(GLOB INCLUDES *.h gcvspl.h)
file(GLOB SOURCES *.cpp gcvspl.c)

# Conditionally compile the C3DFileAdapter based on whether `ezc3d` is available.
# vcpkg defines WITH_EZC3D in the root CMakeLists.txt.
if(NOT WITH_EZC3D)
    file(GLOB C3D_HEADER *C3DFileAdapter.h)
    file(GLOB C3D_SOURCE *C3DFileAdapter.cpp)
    list(REMOVE_ITEM INCLUDES ${C3D_HEADER})
    list(REMOVE_ITEM SOURCES  ${C3D_SOURCE})
endif()

# Create the library target.
add_library(${OSIM_LIB_NAME} SHARED ${SOURCES} ${INCLUDES})

# Set the include directories for this library.
target_include_directories(${OSIM_LIB_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include/OpenSim/Common>
)

# Link against dependent libraries.
# vcpkg provides these targets.
target_link_libraries(${OSIM_LIB_NAME}
    PUBLIC SimTK::SimTKsimbody spdlog::spdlog osimLepton
)
if(WITH_EZC3D)
    target_link_libraries(${OSIM_LIB_NAME} PRIVATE ezc3d::ezc3d)
endif()

# Set properties for Windows DLL export/import and IDE folders.
string(TOUPPER "Common" KIT_UPPER)
set_target_properties(${OSIM_LIB_NAME} PROPERTIES
    DEFINE_SYMBOL OSIM${KIT_UPPER}_EXPORTS
    FOLDER "Libraries"
)

# --- Installation Rules ---

# Install the library target files.
install(TARGETS ${OSIM_LIB_NAME}
    EXPORT OpenSimTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${OPENSIM_INSTALL_ARCHIVEDIR}
)

# Install the header files.
install(FILES ${INCLUDES}
    DESTINATION "include/OpenSim/Common"
)

# This is for running tests in the build tree on Windows.
if(WIN32)
    # On Windows only, debug libraries cannot be mixed with release
    # libraries, and we must copy the DLLs from the dependencies
    # into OpenSim's build directory (so that the DLLs are found
    # when running the tests).
    # vcpkg handles this for release builds, but this may still be
    # needed for debug builds or for tests to find the right DLLs.
    add_dependencies(osimCommon Simbody_CONFIG_check)
    # The Copy_Simbody_DLLs custom target was removed during vcpkg migration,
    # as vcpkg handles copying dependency DLLs for installed targets.
    # If tests fail to run, this may need to be revisited.
    # if(WITH_EZC3D)
    #     add_dependencies(osimCommon Copy_ezc3d_DLLs)
    # endif()
endif()

# Add the testing subdirectory.
if(BUILD_TESTING)
    add_subdirectory(Test)
endif()
