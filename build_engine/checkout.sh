#!/bin/bash -e

# This script checks out the git repos needed to build the engine.
# These are:
#   https://chromium.googlesource.com/chromium/tools/depot_tools.git
#     - This is used to check out our fork of the Flutter engine
#   https://github.com/shorebirdtech/build_engine/
#     - Scripts required to build the engine
#   https://github.com/shorebirdtech/flutter
#     - Our fork of Flutter.
#   https://github.com/shorebirdtech/engine (via gclient sync)
#     - This contains our fork of the Flutter engine and the updater
#
# Usage:
# $ ./checkout.sh ~/.engine_checkout
#
# This will check out all necessary repos into the ~/.engine_checkout directory.

CHECKOUT_ROOT=$(realpath $1)

if [ -z "$CHECKOUT_ROOT" ]; then
    echo "Missing argument: checkout_root"
    echo "Usage: $0 checkout_root"
    exit 1
fi

mkdir -p $CHECKOUT_ROOT
cd $CHECKOUT_ROOT

check_out_depot_tools() {
    cd $CHECKOUT_ROOT
    if [[ ! -d "depot_tools" ]]; then
        git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    fi
    export PATH="$PATH:$CHECKOUT_ROOT/depot_tools"
}

check_out_build_engine() {
    cd $CHECKOUT_ROOT
    if [[ ! -d "build_engine" ]]; then
        git clone https://github.com/shorebirdtech/build_engine.git
    fi
}

check_out_flutter_fork() {
    cd $CHECKOUT_ROOT
    if [[ ! -d "flutter" ]]; then
        git clone https://github.com/shorebirdtech/flutter.git
    fi
    cd flutter
    if [[ ! $(git config --get remote.upstream.url) ]]; then
        git remote add upstream https://github.com/flutter/flutter.git
    fi
    git fetch upstream
}

check_out_engine() {
    cd $CHECKOUT_ROOT
    if [[ ! -d "engine" ]]; then
        mkdir engine
    fi

    cd engine
    curl https://raw.githubusercontent.com/shorebirdtech/build_engine/main/build_engine/dot_gclient >.gclient
    gclient sync

    cd src/flutter
    if [[ ! $(git config --get remote.upstream.url) ]]; then
        git remote add upstream https://github.com/flutter/engine.git
    fi
    git fetch upstream
    git checkout shorebird/dev

    cd $CHECKOUT_ROOT/engine
    gclient sync
}

check_out_depot_tools
check_out_build_engine
check_out_flutter_fork
check_out_engine
