# The vendored libraries are built via vcpkg.
# - docopt is provided by the vcpkg registry.
# - lepton is built via a custom vcpkg port that uses the source code
#   in the lepton/ subdirectory.
# Therefore, we no longer need to call add_subdirectory() here.
