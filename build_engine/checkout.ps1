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
# .\checkout.ps1 -CheckoutRoot C:\path\to\checkout

param (
    [string] $CheckoutRoot
)

function Check-OutDepotTools {
    if (-not (Test-Path -Path "$CheckoutRoot\depot_tools")) {
        git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    }
    $env:PATH += ";$CheckoutRoot\depot_tools"
}

function Check-OutBuildEngine {
    if (-not (Test-Path -Path "$CheckoutRoot\build_engine")) {
        git clone https://github.com/shorebirdtech/build_engine.git 
    }
}

function Check-OutFlutterFork {
    if (-not (Test-Path -Path "$CheckoutRoot\flutter")) {
        git clone https://github.com/shorebirdtech/flutter.git
    }
    Push-Location "$CheckoutRoot\flutter"
    if (-not (git remote get-url upstream)) {
        git remote add upstream https://github.com/flutter/flutter.git
    }
    git fetch upstream
    Pop-Location
}

function Check-OutEngine {
    if (-not (Test-Path -Path "$CheckoutRoot\engine")) {
        New-Item -Name "engine" -ItemType "directory"
    }

    Push-Location "$CheckoutRoot\engine"

    Invoke-WebRequest -Uri "https://raw.githubusercontent.com/shorebirdtech/build_engine/main/build_engine/dot_gclient" -OutFile ".gclient"
    gclient sync

    Push-Location "src\flutter"
    if (-not (git remote get-url upstream)) {
        git remote add upstream https://github.com/flutter/engine.git
    }
    git fetch upstream
    git checkout shorebird/dev
    Pop-Location

    Pop-Location
}

if (-not $CheckoutRoot) {
    Write-Host "Missing argument: CheckoutRoot"
    exit 1
}

if (-not (Test-Path -Path $CheckoutRoot)) {
    New-Item -Path $CheckoutRoot -ItemType Directory
}

Push-Location $CheckoutRoot

Check-OutDepotTools
Check-OutBuildEngine
Check-OutFlutterFork
Check-OutEngine

Pop-Location
