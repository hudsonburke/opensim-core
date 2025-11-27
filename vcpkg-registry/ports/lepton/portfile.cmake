# Set the source path to the vendored lepton directory
set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../Vendors/lepton")

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "Lepton")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Copy the license file
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
