#!/bin/sh -e

# Usage:
# ./update.sh engine_path engine_hash

# The path to the Flutter engine.
ENGINE_ROOT=$1
ENGINE_HASH=$2

# Update Dart and the engine to make sure we have all the tags from upstream.
# The version number in the builds seems to depend on these tags?
cd $ENGINE_ROOT/src/third_party/dart
git fetch
git fetch --tags upstream

# First update our checkouts to the correct versions.
# gclient sync -r src/flutter@${ENGINE_HASH}
# doesn't seem to work, it seems to get stuck trying to
# rebase the engine repo. So we do it manually.
# Similar to https://bugs.chromium.org/p/chromium/issues/detail?id=584742
cd $ENGINE_ROOT/src/flutter
git fetch
git fetch --tags upstream
git checkout $ENGINE_HASH

cd $ENGINE_ROOT
gclient sync
