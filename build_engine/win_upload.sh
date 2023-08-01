#!/bin/sh -e

# Usage:
# ./win_upload.sh engine_path git_hash
ENGINE_ROOT=$1
ENGINE_HASH=$2

STORAGE_BUCKET="download.shorebird.dev"
SHOREBIRD_ROOT=gs://$STORAGE_BUCKET/shorebird/$ENGINE_HASH

ENGINE_SRC=$ENGINE_ROOT/src
ENGINE_OUT=$ENGINE_SRC/out
ENGINE_FLUTTER=$ENGINE_SRC/flutter

cd $ENGINE_FLUTTER

# We do not generate a manifest file, we assume another builder did that.

# TODO(eseidel): This should not be in shell, it's too complicated/repetative.

HOST_ARCH='windows-x64'

INFRA_ROOT="gs://$STORAGE_BUCKET/flutter_infra_release/flutter/$ENGINE_HASH"

# TODO(eseidel): Hack for eseidel's machine.
export PATH="$PATH:/c/Users/micro/AppData/Local/cloud-code/installer/google-cloud-sdk/bin"

# Android Arm64 release gen_snapshot
# ARCH_OUT=$ENGINE_OUT/android_release_arm64
# ZIPS_OUT=$ARCH_OUT/zip_archives/android-arm64-release
# ZIPS_DEST=$INFRA_ROOT/android-arm64-release
# gsutil cp $ZIPS_OUT/$HOST_ARCH.zip $ZIPS_DEST/$HOST_ARCH.zip

# Android Arm32 release gen_snapshot
ARCH_OUT=$ENGINE_OUT/android_release
ZIPS_OUT=$ARCH_OUT/zip_archives/android-arm-release
ZIPS_DEST=$INFRA_ROOT/android-arm-release
gsutil cp $ZIPS_OUT/$HOST_ARCH.zip $ZIPS_DEST/$HOST_ARCH.zip

# Android x64 release gen_snapshot
ARCH_OUT=$ENGINE_OUT/android_release_x64
ZIPS_OUT=$ARCH_OUT/zip_archives/android-x64-release
ZIPS_DEST=$INFRA_ROOT/android-x64-release
gsutil cp $ZIPS_OUT/$HOST_ARCH.zip $ZIPS_DEST/$HOST_ARCH.zip

# We could upload patch if we built it here.
# gsutil cp $ENGINE_OUT/host_release/patch.zip $SHOREBIRD_ROOT/patch-win-x64.zip
