#!/bin/sh -e

# Usage:
# ./mac_build_and_upload.sh engine_path engine_hash

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
./mac_build.sh $ENGINE_ROOT

# Copy Shorebird engine artifacts to Google Cloud Storage.
./mac_upload.sh $ENGINE_ROOT $ENGINE_HASH
