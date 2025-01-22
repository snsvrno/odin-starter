#!/usr/bin/fish

# list of builds that are available, used by `build.fish`
# uncomment / modify as needed

# some variables that will be project specific
set SRC_PATH src
set OUT_PATH bin
set EXE_NAME game

set build_options \
	-json-errors

#things that must be set in order to get the hot reload working properly
set dev_only_options \
	-define:RAYLIB_SHARED=true

# checks if we are 100% commited, or if there is some un tracked stuff
set git_status "*"; if test -z "$(git status --porcelain)"; set git_status ""; end
set build_vars \
	-define:GAME_VERSION="$(git describe --abbrev=0)" \
	-define:BUILD_ARTIFACT=\""$(git rev-parse --short HEAD)$git_status"\" \
	-define:BUILD_TIME="$(date +%y-%j-%H%M)"

################################################
# builds
# main desktop release
set build_release_folder $OUT_PATH/release
set build_release "release" build runner/release -out:$build_release_folder/$EXE_NAME $build_options $build_vars
# dev desktop
set build_dev_folder $OUT_PATH/dev
set build_dev "dev/runner" build runner/dev -out:$OUT_PATH/dev/game \
	-debug $dev_only_options $build_options $bulid_vars
# dev library
set build_dev_lib "dev/library" build src -out:$OUT_PATH/dev/game.so \
	-debug -build-mode:dll $dev_only_options $build_options $bulid_vars

################################################
# tools that are in the project
# res builder
set tool_res "tools/res" "tools/res/run.fish" -src=res -target=$SRC_PATH/res.odin
