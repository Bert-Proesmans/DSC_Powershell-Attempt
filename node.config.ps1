$certFilePath = "$PSScriptRoot/DscPublicKey.cer"

if (-not(Test-Path -Path $certFilePath -PathType Leaf)) {
    $cert = New-SelfSignedCertificate -DnsName 'DscEncryptionCert' `
        -CertStoreLocation 'Cert:\LocalMachine\my' `
        -Type DocumentEncryptionCertLegacyCsp -HashAlgorithm SHA256
    $cert | Export-Certificate -FilePath $certFilePath -Force
}

$certThumbprint = Get-ChildItem -Path 'Cert:\LocalMachine\my' `
| Where-Object { $_.Subject -Match 'DscEncryptionCert' } `
| Select-Object -First 1 -Expand Thumbprint

$adminUser = 'Administrator'
# NOTE; -AsPlainText acknowledges that the string to convert from is plain text
# WARN; -Force is required with -AsPlainText because storing plaintext passwords in scripts is bad practise
$adminPass = ConvertTo-SecureString -String 'InsecurePa$$word!' -AsPlainText -Force
$adminCredential = New-Object -TypeName System.Management.Automation.PSCredential `
    -ArgumentList $adminUser, $adminPass


$configData = @{
    AllNodes = @(
        @{
            # START implicit configuration
            NodeName              = 'localhost'
            # PsDscAllowPlainTextPassword = $true
            # PSDscAllowDomainUser = $true
            CertificateFile       = $certFilePath
            Thumbprint            = $certThumbprint
            # END implicit configuration

            Role                  = 'Primary DC'
            DomainAdminCredential = $adminCredential
        }
    )
}