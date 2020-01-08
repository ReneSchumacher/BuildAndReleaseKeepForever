if (Test-Path .\BuildReleaseRetentionTask\ps_modules\VstsTaskSdk)
{
    Remove-Item -Recurse -Force .\BuildReleaseRetentionTask\ps_modules\VstsTaskSdk
}
New-Item .\sdk_download -ItemType Directory
Save-Module -Name VstsTaskSdk -Path .\sdk_download

New-Item .\BuildReleaseRetentionTask\ps_modules\VstsTaskSdk -ItemType Directory
$VstsTaskModule = Get-ChildItem VstsTaskSdk.psd1 -Recurse
Copy-Item -Recurse "$($VstsTaskModule.Directory)\*" .\BuildReleaseRetentionTask\ps_modules\VstsTaskSdk

Remove-Item -Recurse -Force .\sdk_download

tfx extension create --manifest-globs .\vss-extension.json