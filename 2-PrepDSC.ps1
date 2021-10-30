#requires -version 7.1
#requires -RunasAdministrator

# ERROR; DesiredStateConfiguration runs under LOCAL_SYSTEM account, so it uses systemwide
# environment variables.
# Powershell core variants use 'C:\Program Files\PowerShell\Modules' as AllUsers (scope) module installation path,
# so this path needs to be added!
$key = (Get-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager').OpenSubKey('Environment', $true)
$path = $key.GetValue('PSModulePath', '', 'DoNotExpandEnvironmentNames')
if (-not ($path -contains '%ProgramFiles%\PowerShell\Modules')) {
    # FIX; DSC resource MSFT_WindowsOptionalFeature from module <PSDscResources,X.XX.X.X> does not exist at the PowerShell module path
    $path += ';%ProgramFiles%\PowerShell\Modules'
    $key.SetValue('PSModulePath', $path, [Microsoft.Win32.RegistryValueKind]::ExpandString)
}

(Get-PackageProvider -Name 'NuGet') `
    -or (Install-PackageProvider -Name 'NuGet' -MinimumVersion '2.8.5.201' -Force -Verbose)
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -Verbose

(Get-InstalledModule -Name 'PSDscResources' -MinimumVersion '2.12.0.0') `
    -or (Install-Module 'PSDscResources' -MinimumVersion '2.12.0.0' -Scope AllUsers -Repository 'PSGallery' -Verbose)
(Get-InstalledModule -Name ActiveDirectoryDsc -MinimumVersion '6.0.1') `
    -or (Install-Module 'ActiveDirectoryDsc' -MinimumVersion '6.0.1' -Scope AllUsers -Repository 'PSGallery' -Verbose)

. "$PSScriptRoot/node.config.ps1"

. "$PSScriptRoot/StateConfiguration.ps1"
DSCConfig -ConfigurationData $configData -OutputPath:"$PSScriptRoot/machine-configuration"

# NOTE; Copy ./machine-configuration/*.mof file to %windir%\System32\Configuration\Pending.mof for cloud-init-like state configuration

Start-DscConfiguration -Path:"$PSScriptRoot/machine-configuration" -Force -Wait -Verbose
# Get-DscConfiguration