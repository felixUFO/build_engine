#!/bin/sh -e

# Usage:
# ./update.sh engine_path engine_hash

# The path to the Flutter engine.
ENGINE_ROOT=$1
ENGINE_HASH=$2

# First update our checkouts to the correct versions.
# gclient sync -r src/flutter@${ENGINE_HASH}
# doesn't seem to work, it seems to get stuck trying to
# rebase the engine repo. So we do it manually.
# Similar to https://bugs.chromium.org/p/chromium/issues/detail?id=584742
cd $ENGINE_ROOT/src/flutter
git fetch
git checkout $ENGINE_HASH

cd $ENGINE_ROOT
DEPOT_TOOLS_WIN_TOOLCHAIN=0 gclient sync

# Update Dart and the engine to make sure we have all the tags from upstream.
# The version number in the builds seems to depend on these tags?
cd $ENGINE_ROOT/src/third_party/dart
if [[ ! $(git config --get remote.upstream.url) ]]; then
    git remote add upstream https://dart.googlesource.com/sdk.git
fi
git fetch
git fetch --tags upstream

cd $ENGINE_ROOT/src/flutter
if [[ ! $(git config --get remote.upstream.url) ]]; then
    git remote add upstream https://github.com/flutter/engine.git
fi
git fetch
git fetch --tags upstream