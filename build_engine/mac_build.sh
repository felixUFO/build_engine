#!/bin/sh -e

# FIXME: This script should be deleted and instead these steps be part
# of the GN build process.
# I haven't investigated how to build rust from GN with the Android NDK yet.

# Usage:
# ./mac_build.sh engine_path

ENGINE_ROOT=$1

ENGINE_SRC=$ENGINE_ROOT/src
ENGINE_OUT=$ENGINE_SRC/out
UPDATER_SRC=$ENGINE_SRC/third_party/updater

# Build the Rust library.
cd $UPDATER_SRC/library

# Use the same NDK as the Flutter engine.
# Use -p 16 to match Flutter's minAndroidSdkVersion
NDK_HOME="$ENGINE_SRC/third_party/android_tools/ndk" \
    cargo ndk \
    -p 16 \
    --target armv7-linux-androideabi \
    build --release

# Flutter's NDK only includes libunwind for armv7 our current Rust build
# seems to depend on it existing:
# https://github.com/flutter/flutter/issues/124280
# FIXME: Using Android Studio NDK for now, this won't work on the bots!
cargo ndk \
    --target aarch64-linux-android \
    --target x86_64-linux-android \
    --target i686-linux-android \
    build --release

# Build iOS
cargo build --target aarch64-apple-ios --target x86_64-apple-ios --release

# Build the patch tool.
# Again, this belongs as part of the gn build.
cd $UPDATER_SRC/patch
cargo build --release

# Compile the engine using the steps here:
# https://github.com/flutter/flutter/wiki/Compiling-the-engine#compiling-for-android-from-macos-or-linux
cd $ENGINE_SRC

# FIXME: These build commands likely could build fewer targets.

# Android arm64 release
./flutter/tools/gn --android --android-cpu=arm64 --runtime-mode=release --no-goma
ninja -C ./out/android_release_arm64 -j 4

# Hack for now. This assumes we're building on a Mac arm64 host.
# Again, this should be in gn (or patch itself be re-written in Dart).
mkdir -p $ENGINE_OUT/host_release_arm64
cp $UPDATER_SRC/target/release/patch $ENGINE_OUT/host_release_arm64/patch
zip -j $ENGINE_OUT/host_release_arm64/patch.zip $ENGINE_OUT/host_release_arm64/patch

# Android arm32 release
./flutter/tools/gn --android --runtime-mode=release --no-goma
ninja -C ./out/android_release -j 4

# Android x64 release
./flutter/tools/gn --android --android-cpu=x64 --runtime-mode=release --no-goma
ninja -C ./out/android_release_x64 -j 4

# Dart doesn't allow building for x86 from a 64-bit host:
# # Android x86 release
# ./flutter/tools/gn --android --android-cpu=x86 --runtime-mode=release --no-goma
# ninja -C ./out/android_release_x86


# We would ideally only need to build the arm64 release, but because we change
# the commit hash for Dart, we need to build all 3 archs so that we don't
# have a snapshot mismatch error on execution.

# `--no-enable-unittests` is needed on Flutter 3.10.1 and 3.10.2 to avoid
# https://github.com/flutter/flutter/issues/128135

# We only need two targets (per the mac builders):
# "flutter/shell/platform/darwin/ios:flutter_framework",
# "flutter/lib/snapshot:generate_snapshot_bin"
# https://github.com/flutter/engine/blob/main/ci/builders/mac_ios_engine.json#L139
# https://github.com/flutter/engine/blob/main/ci/builders/README.md

# iOS arm64 release
./flutter/tools/gn --no-goma --runtime-mode=release --no-enable-unittests --ios --gn-arg='dart_force_simulator=true'
ninja -C out/ios_release flutter/shell/platform/darwin/ios:flutter_framework flutter/lib/snapshot:generate_snapshot_bin

# iOS simulator-x64 release
./flutter/tools/gn --no-goma --runtime-mode=debug --no-enable-unittests --ios --simulator
ninja -C out/ios_debug_sim flutter/shell/platform/darwin/ios:flutter_framework flutter/lib/snapshot:generate_snapshot_bin

# iOS simulator-arm64 release
./flutter/tools/gn --no-goma --runtime-mode=debug --no-enable-unittests --ios --simulator --simulator-cpu=arm64
ninja -C out/ios_debug_sim_arm64 flutter/shell/platform/darwin/ios:flutter_framework flutter/lib/snapshot:generate_snapshot_bin

# We have to create a composite Flutter.framework for iOS, matching what
# the Flutter builders do:
python3 flutter/sky/tools/create_full_ios_framework.py \
    --dst out/release \
    --arm64-out-dir out/ios_release \
    --simulator-x64-out-dir out/ios_debug_sim \
    --simulator-arm64-out-dir out/ios_debug_sim_arm64 \
    --dsym \
    --strip