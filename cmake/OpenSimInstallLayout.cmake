# This module configures the installation directory layout for OpenSim based on
# the OPENSIM_INSTALL_UNIX_FHS option.

## OPENSIM_INSTALL_UNIX_FHS option.
set(OPENSIM_INSTALL_UNIX_FHS_DEFAULT OFF)
if(UNIX)
  set(OPENSIM_INSTALL_UNIX_FHS_DEFAULT ON)
endif()

option(OPENSIM_INSTALL_UNIX_FHS
    "Organize installation according to UNIX Filesystem Hierarchy Standard."
    ${OPENSIM_INSTALL_UNIX_FHS_DEFAULT})

if(WIN32)
  # Windows users probably aren't interested in this option.
  mark_as_advanced(OPENSIM_INSTALL_UNIX_FHS)
endif()

## Set variables describing where everything gets installed.
if(${OPENSIM_INSTALL_UNIX_FHS})

  # Sets CMAKE_INSTALL_*DIR variables, some of which are used below.
  include(GNUInstallDirs)

  set(OPENSIM_INSTALL_ARCHIVEDIR "${CMAKE_INSTALL_LIBDIR}")
  set(OPENSIM_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/OpenSim")
  # Location of the opensim python package in the installation.
  # We replace VERSION with the correct version once we know it (in
  # Bindings/Python/CMakeLists.txt).
  if (OPENSIM_PYTHON_CONDA)
    set(OPENSIM_INSTALL_PYTHONDIR "Lib/site-packages")
  else()
    set(OPENSIM_INSTALL_PYTHONDIR "lib/pythonVERSION/site-packages")
  endif()
  set(OPENSIM_INSTALL_JAVAJARDIR "${CMAKE_INSTALL_DATAROOTDIR}/java")
  set(OPENSIM_INSTALL_JAVASRCDIR "${CMAKE_INSTALL_DATAROOTDIR}/OpenSim/java")
  set(OPENSIM_INSTALL_APIEXDIR "${CMAKE_INSTALL_DOCDIR}/Code")
  set(OPENSIM_INSTALL_SIMBODYDIR ".")
  set(OPENSIM_INSTALL_SPDLOGDIR ".")
  set(OPENSIM_INSTALL_CASADIDIR ".")

else()

  # Use our own installation layout.
  set(CMAKE_INSTALL_BINDIR bin)
  set(CMAKE_INSTALL_INCLUDEDIR sdk/include)
  set(CMAKE_INSTALL_LIBDIR sdk/lib)
  set(CMAKE_INSTALL_DOCDIR sdk/doc)
  set(CMAKE_INSTALL_SYSCONFDIR sdk)

  set(OPENSIM_INSTALL_ARCHIVEDIR "${CMAKE_INSTALL_LIBDIR}")
  set(OPENSIM_INSTALL_CMAKEDIR cmake)
  set(OPENSIM_INSTALL_PYTHONDIR sdk/Python)
  set(OPENSIM_INSTALL_JAVAJARDIR sdk/Java)
  set(OPENSIM_INSTALL_JAVASRCDIR sdk/Java)
  set(OPENSIM_INSTALL_APIEXDIR Resources/Code)
  set(OPENSIM_INSTALL_SIMBODYDIR sdk/Simbody)
  set(OPENSIM_INSTALL_SPDLOGDIR sdk/spdlog)
  set(OPENSIM_INSTALL_CASADIDIR sdk)

endif()

set(OPENSIM_INSTALL_CPPEXDIR "${OPENSIM_INSTALL_APIEXDIR}/CPP")
set(OPENSIM_INSTALL_MATLABEXDIR "${OPENSIM_INSTALL_APIEXDIR}/Matlab")
set(OPENSIM_INSTALL_PYTHONEXDIR "${OPENSIM_INSTALL_APIEXDIR}/Python")

# Cross-platform location of shared libraries. Used in configureOpenSim.m.
if(WIN32)
  set(OPENSIM_INSTALL_SHAREDLIBDIR "${CMAKE_INSTALL_BINDIR}")
else()
  set(OPENSIM_INSTALL_SHAREDLIBDIR "${CMAKE_INSTALL_LIBDIR}")
endif()

# On UNIX, be careful about installing into system directories.
get_filename_component(ABS_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}" REALPATH)
if(UNIX AND ("${ABS_INSTALL_PREFIX}" STREQUAL "/usr" OR
             "${ABS_INSTALL_PREFIX}" STREQUAL "/usr/local"))
  set(no_name_conflict ${BUILD_API_ONLY} OR NOT ${OPENSIM_BUILD_INDIVIDUAL_APPS})
  if(${OPENSIM_INSTALL_UNIX_FHS} AND ${no_name_conflict})
    # In this case it's fine to install into /usr or /usr/local.
  else()
    message(SEND_ERROR "
        Cannot install into /usr or /usr/local if the OpenSim installation does
        not conform to the UNIX Filesystem Hierarchy Standard or if building
        the old command-line applications (there are name conflicts with vital
        UNIX executables). Either (a) set OPENSIM_INSTALL_UNIX_FHS to ON, or
        (b) change CMAKE_INSTALL_PREFIX.")
  endif()
endif()
