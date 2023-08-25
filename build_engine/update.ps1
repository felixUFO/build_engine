# Usage:
# .\update.ps1 -EnginePath engine_path -EngineHash engine_hash

param (
    [string] $EnginePath,
    [string] $EngineHash
)

# The path to the Flutter engine.
$EngineRoot = Get-Item -Path $EnginePath
$EngineHash = $EngineHash

# First update our checkouts to the correct versions.
# gclient sync -r src/flutter@${ENGINE_HASH}
# doesn't seem to work, it seems to get stuck trying to
# rebase the engine repo. So we do it manually.
# Similar to https://bugs.chromium.org/p/chromium/issues/detail?id=584742
Push-Location "$EngineRoot\src\flutter"
git fetch
git checkout $EngineHash

Push-Location $EngineRoot
gclient sync

# Update Dart and the engine to make sure we have all the tags from upstream.
# The version number in the builds seems to depend on these tags?
Push-Location "$EngineRoot\src\third_party\dart"
if (-not (git remote get-url upstream)) {
    git remote add upstream https://dart.googlesource.com/sdk.git
}
git fetch
git fetch --tags upstream

Push-Location "$EngineRoot\src\flutter"
if (-not (git remote get-url upstream)) {
    git remote add upstream https://github.com/flutter/engine.git
}
git fetch
git fetch --tags upstream

Pop-Location
