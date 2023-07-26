#!/bin/sh -e

# Usage:
# ./win_build.sh engine_path

ENGINE_ROOT=$1

ENGINE_SRC=$ENGINE_ROOT/src
ENGINE_OUT=$ENGINE_SRC/out

# Compile the engine using the steps here:
# https://github.com/flutter/flutter/wiki/Compiling-the-engine#compiling-for-android-from-macos-or-linux
cd $ENGINE_SRC

# Windows only needs gen_snapshot for each Android CPU type.
# See https://github.com/flutter/engine/blob/e590b24f3962fda3ec9144dcee3f7565b195839a/ci/builders/windows_android_aot_engine.json


# If this gives you trouble, try using VS2019 instead.  I had trouble with 2022.
# Android arm64 release
./flutter/tools/gn --android --android-cpu=arm64 --runtime-mode=release --no-goma
ninja -C ./out/android_release_arm64 archive_win_gen_snapshot

# Android arm32 release
./flutter/tools/gn --runtime-mode=release --android --no-goma
ninja -C out/android_release archive_win_gen_snapshot

# Android x64 release
./flutter/tools/gn --android --android-cpu=x64 --runtime-mode=release --no-goma
ninja -C ./out/android_release_x64 archive_win_gen_snapshot

# We could also build the `patch` tool for Windows here.
