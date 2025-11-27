
# Define the library name.
set(OSIM_LIB_NAME osimSimulation)

# Gather source and header files.
set(SIMULATION_SUBDIRS
        .
        Control
        Manager
        Model
        Wrap
        SimbodyEngine
        OpenSense)

set(SOURCES)
set(INCLUDES)
set(INCLUDE_DIRS_FULL)
foreach(dir ${SIMULATION_SUBDIRS})
    set(full_dir_path "${CMAKE_CURRENT_SOURCE_DIR}/${dir}")
    file(GLOB_RECURSE SOURCES_ONEDIR "${full_dir_path}/*.cpp")
    file(GLOB_RECURSE INCLUDES_ONEDIR "${full_dir_path}/*.h")
    list(APPEND SOURCES ${SOURCES_ONEDIR})
    list(APPEND INCLUDES ${INCLUDES_ONEDIR})
    list(APPEND INCLUDE_DIRS_FULL ${full_dir_path})
endforeach()

# Create the library target from the collected sources.
add_library(${OSIM_LIB_NAME} SHARED ${SOURCES} ${INCLUDES})

# Set the include directories for this library.
# PUBLIC: So that targets linking against this library also get these includes.
target_include_directories(${OSIM_LIB_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${INCLUDE_DIRS_FULL}>
        $<INSTALL_INTERFACE:include/OpenSim/Simulation>
)

# Link against dependent libraries.
# PUBLIC: So that targets linking against this library also link to these.
# vcpkg will find Simbody and Lepton.
target_link_libraries(${OSIM_LIB_NAME} PUBLIC osimCommon SimTK::SimTKsimbody osimLepton)

# Set properties for Windows DLL export/import.
string(TOUPPER "Simulation" KIT_UPPER)
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
    ARCHIVE DESTINATION ${CMAKE_INSTALL_ARCHIVEDIR}
)

# Install the header files.
set(INSTALL_INCLUDE_PREFIX "include/OpenSim/Simulation")
foreach(dir ${SIMULATION_SUBDIRS})
    file(GLOB HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*.h")
    if(HEADERS)
        if(dir STREQUAL ".")
            set(install_subdir "")
        else()
            set(install_subdir "/${dir}")
        endif()
        install(FILES ${HEADERS}
            DESTINATION "${INSTALL_INCLUDE_PREFIX}${install_subdir}"
        )
    endif()
endforeach()

# Add the testing subdirectories.
if(BUILD_TESTING)
    add_subdirectory(SimbodyEngine)
    add_subdirectory(Test)
endif()
