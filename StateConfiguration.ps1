Configuration DSCConfig {
    Param ()

    Import-DscResource -ModuleName 'PSDscResources'
    Import-DscResource -ModuleName 'ActiveDirectoryDsc'

    Node $AllNodes.Where{ $_.Role -eq "Primary DC" }.NodeName {
        
        WindowsFeature 'ADDS' {
            Name   = 'AD-Domain-Services'
            Ensure = 'Present'
        }

        WindowsFeature 'RSAT' {
            Name   = 'RSAT-AD-PowerShell'
            Ensure = 'Present'
        }

        User $Node.DomainAdminCredential.UserName {
            Ensure   = 'Present'
            UserName = $Node.DomainAdminCredential.UserName
            Password = $Node.DomainAdminCredential
        }

        ADDomain 'ad.alpha.proesmans.eu' {
            DomainName                    = 'ad.alpha.proesmans.eu'
            Credential                    = $Node.DomainAdminCredential
            SafemodeAdministratorPassword = $Node.DomainAdminCredential
            ForestMode                    = 'WinThreshold'
        }

        WaitForADDomain 'ad.alpha.proesmans.eu' {
            DomainName = 'ad.alpha.proesmans.eu'
        }
    }
}