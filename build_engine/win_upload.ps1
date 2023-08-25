# Usage:
# .\win_upload.ps1 -EnginePath engine_path -EngineHash git_hash

param (
    [string] $EnginePath,
    [string] $EngineHash
)

$StorageBucket = "download.shorebird.dev"
$ShorebirdRoot = "gs://$StorageBucket/shorebird/$EngineHash"

$EngineSrc = Join-Path $EnginePath "src"
$EngineOut = Join-Path $EngineSrc "out"
$EngineFlutter = Join-Path $EngineSrc "flutter"

Push-Location $EngineFlutter

# We do not generate a manifest file, we assume another builder did that.

# TODO: This should not be in PowerShell, it's too complicated/repetitive.

$HostArch = 'windows-x64'

$InfraRoot = "gs://$StorageBucket/flutter_infra_release/flutter/$EngineHash"

# TODO: Hack for eseidel's machine.
$env:PATH += ";C:\Users\micro\AppData\Local\cloud-code\installer\google-cloud-sdk\bin"

# Android Arm64 release gen_snapshot
$ArchOut = Join-Path $EngineOut "android_release_arm64"
$ZipsOut = Join-Path $ArchOut "zip_archives/android-arm64-release"
$ZipsDest = Join-Path $InfraRoot "android-arm64-release"
gsutil cp "$ZipsOut\$HostArch.zip" "$ZipsDest\$HostArch.zip"

# Android Arm32 release gen_snapshot
$ArchOut = Join-Path $EngineOut "android_release"
$ZipsOut = Join-Path $ArchOut "zip_archives/android-arm-release"
$ZipsDest = Join-Path $InfraRoot "android-arm-release"
gsutil cp "$ZipsOut\$HostArch.zip" "$ZipsDest\$HostArch.zip"

# Android x64 release gen_snapshot
$ArchOut = Join-Path $EngineOut "android_release_x64"
$ZipsOut = Join-Path $ArchOut "zip_archives/android-x64-release"
$ZipsDest = Join-Path $InfraRoot "android-x64-release"
gsutil cp "$ZipsOut\$HostArch.zip" "$ZipsDest\$HostArch.zip"

# We could upload patch if we built it here.
# gsutil cp "$EngineOut/host_release/patch.zip" "$ShorebirdRoot/patch-win-x64.zip"

Pop-Location
