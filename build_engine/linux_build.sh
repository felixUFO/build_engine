#!/bin/sh -e

# Usage:
# ./win_build.sh engine_path

ENGINE_ROOT=$1

ENGINE_SRC=$ENGINE_ROOT/src
ENGINE_OUT=$ENGINE_SRC/out

# Compile the engine using the steps here:
# https://github.com/flutter/flutter/wiki/Compiling-the-engine#compiling-for-android-from-macos-or-linux
cd $ENGINE_SRC

# We could use Linux to generate all of our Android binaries, but we don't yet.
# https://github.com/flutter/engine/blob/e590b24f3962fda3ec9144dcee3f7565b195839a/ci/builders/linux_android_aot_engine.json#L40

# Linux doesn't seem to use "archive_gen_snapshot" as a target name yet.
# https://github.com/flutter/flutter/issues/105351#issuecomment-1650686247
TARGETS="new_gen_snapshot"

# Android arm64 release
./flutter/tools/gn --android --android-cpu=arm64 --runtime-mode=release --no-goma
ninja -C ./out/android_release_arm64 $TARGETS

# Android arm32 release
./flutter/tools/gn --runtime-mode=release --android --no-goma
ninja -C out/android_release $TARGETS

# Android x64 release
./flutter/tools/gn --android --android-cpu=x64 --runtime-mode=release --no-goma
ninja -C ./out/android_release_x64 $TARGETS

# We could also build the `patch` tool for Linux here.
