[DscLocalConfigurationManager()]
Configuration LCMConfig {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $PrivateKeyThumbprint
    )

    Node localhost {
        Settings {
            RefreshMode                    = 'Push'
            RebootNodeIfNeeded             = $true
            ActionAfterReboot              = 'ContinueConfiguration'
            ConfigurationMode              = 'ApplyAndAutoCorrect'
            ConfigurationModeFrequencyMins = 15
            CertificateID                  = $PrivateKeyThumbprint
        }
    }
}