add_executable(opensim-cmd opensim-cmd.cpp
    opensim-cmd_run-tool.h
    opensim-cmd_print-xml.h
    opensim-cmd_info.h
    opensim-cmd_update-file.h
    parse_arguments.h
)

target_link_libraries(opensim-cmd PUBLIC osimTools osimMoco docopt.cpp::docopt)

set_target_properties(opensim-cmd PROPERTIES FOLDER "Applications")

install(TARGETS opensim-cmd DESTINATION ${CMAKE_INSTALL_BINDIR})

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
