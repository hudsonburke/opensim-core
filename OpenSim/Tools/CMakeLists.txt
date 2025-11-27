# Define the library name.
set(OSIM_LIB_NAME osimTools)

# Gather source and header files.
file(GLOB INCLUDES *.h)
file(GLOB SOURCES *.cpp)

# Create the library target.
add_library(${OSIM_LIB_NAME} SHARED ${SOURCES} ${INCLUDES})

# Set the include directories for this library.
target_include_directories(${OSIM_LIB_NAME}
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include/OpenSim/Tools>
)

# Link against dependent libraries.
target_link_libraries(${OSIM_LIB_NAME} PUBLIC osimCommon osimSimulation osimActuators osimAnalyses)

# Set properties for Windows DLL export/import and IDE folders.
string(TOUPPER "Tools" KIT_UPPER)
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
    DESTINATION "include/OpenSim/Tools"
)

# Add the testing subdirectory.
if(BUILD_TESTING)
    add_subdirectory(Test)
endif()
