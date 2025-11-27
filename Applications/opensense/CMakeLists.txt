add_executable(opensense opensense.cpp)
target_link_libraries(opensense PUBLIC osimTools)
set_target_properties(opensense PROPERTIES FOLDER "Applications")
install(TARGETS opensense DESTINATION ${CMAKE_INSTALL_BINDIR})

if(BUILD_TESTING)
    add_subdirectory(test)
endif()
