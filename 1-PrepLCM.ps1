#requires -version 7.1
#requires -RunasAdministrator

. "$PSScriptRoot/node.config.ps1"

. "$PSScriptRoot/ConfigurationManager.ps1"
LCMConfig -OutputPath:"$PSScriptRoot/configuration-manager" `
    -PrivateKeyThumbprint ($configData.AllNodes | Where-Object { $_.NodeName -eq 'localhost' } | Select-Object -First 1 -Expand Thumbprint)

# NOTE; Copy ./configuration-manager/*.meta.mof file to %windir%\System32\Configuration\MetaConfig.mof for cloud-init-like state configuration

Set-DSCLocalConfigurationManager -Path:"$PSScriptRoot/configuration-manager" -Verbose
Get-DscLocalConfigurationManager