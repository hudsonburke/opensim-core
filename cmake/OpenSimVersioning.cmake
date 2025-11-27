# This module determines the OPENSIM_QUALIFIED_VERSION for the project.

set(OPENSIM_MAJOR_VERSION 4)
set(OPENSIM_MINOR_VERSION 5)
set(OPENSIM_PATCH_VERSION 2)

# Don't include the patch version if it is 0.
set(PATCH_VERSION_STRING)
if(OPENSIM_PATCH_VERSION)
  set(PATCH_VERSION_STRING ".${OPENSIM_PATCH_VERSION}")
endif()

set(OPENSIM_RELEASE_VERSION
    "${OPENSIM_MAJOR_VERSION}.${OPENSIM_MINOR_VERSION}${PATCH_VERSION_STRING}"
    )

# The OPENSIM_QUALIFIED_VERSION is more granular than OPENSIM_RELEASE_VERSION.
# If git is not found, we simply append "?" to the release version.
# If the checked-out commit is tagged, the qualified version is the tag name.
# If the checked-out commit is not tagged, the qualified version is
#   <release-version>-<git-commit-date>-<git-commit-short-hash>
#   For example: 4.2-2020-07-01-5c10b4176
set(QUALIFIED_VERSION "")
find_package(Git)
if(Git_FOUND)
  # This command provides the annotated tag for the current commit, if it
  # exists, and returns an error if a tag does not exist.
  execute_process(
            COMMAND "${GIT_EXECUTABLE}" describe --exact-match
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE GIT_DESCRIBE_EXACT_MATCH_RETVAL
            OUTPUT_VARIABLE GIT_TAG
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
    )
  if(${GIT_DESCRIBE_EXACT_MATCH_RETVAL} EQUAL 0)
    # A tag exists.
    set(QUALIFIED_VERSION ${GIT_TAG})
    # Do not add anything to the version.
  else()
    execute_process(
                COMMAND "${GIT_EXECUTABLE}" log -1 --format=%h
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE GIT_COMMIT_HASH
                OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    # Prepend date for sorting.
    execute_process(
                COMMAND "${GIT_EXECUTABLE}" show -s --format=%cd --date=short HEAD
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                OUTPUT_VARIABLE GIT_COMMIT_DATE
                OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    set(QUALIFIED_VERSION
                "${OPENSIM_RELEASE_VERSION}-${GIT_COMMIT_DATE}-${GIT_COMMIT_HASH}")
  endif()
else()
  set(QUALIFIED_VERSION "${OPENSIM_RELEASE_VERSION}?")
endif()
set(OPENSIM_QUALIFIED_VERSION "${QUALIFIED_VERSION}" CACHE STRING
        "Qualified version string, containing git commit date/hash suffix." FORCE)
