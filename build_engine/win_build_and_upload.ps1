# Usage:
# .\win_build_and_upload.ps1 -EnginePath engine_path -EngineHash engine_hash

param (
    [string] $EnginePath,
    [string] $EngineHash
)

# Get the absolute path to the directory of this script.
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Building engine at $EnginePath and uploading to gs://download.shorebird.dev"

Push-Location $ScriptDir

# Update our checkouts to the correct versions.
.\update.ps1 -EnginePath $EnginePath -EngineHash $EngineHash

# Then run the build (this should just be a ninja call).
.\win_build.ps1 -EnginePath $EnginePath

# Copy Shorebird engine artifacts to Google Cloud Storage.
.\win_upload.ps1 -EnginePath $EnginePath -EngineHash $EngineHash

Pop-Location
