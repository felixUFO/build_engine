#!/bin/sh -e

# Usage:
# ./linux_build_and_upload.sh engine_path engine_hash

# Example:
# ./build_engine/build_engine/linux_build_and_upload.sh \
#  $HOME/Documents/GitHub/engine \
# c906e2c58ff7cd8f57f5207c109559d1a9f1ce04

# The path to the Flutter engine.
ENGINE_ROOT=$1
ENGINE_HASH=$2

# Get the absolute path to the directory of this script.
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

echo "Building engine at $ENGINE_ROOT and uploading to gs://download.shorebird.dev"

cd $SCRIPT_DIR

# Update our checkouts to the correct versions.
./update.sh $ENGINE_ROOT $ENGINE_HASH

# Then run the build (this should just be a ninja call).
./linux_build.sh $ENGINE_ROOT

# Copy Shorebird engine artifacts to Google Cloud Storage.
./linux_upload.sh $ENGINE_ROOT $ENGINE_HASH
