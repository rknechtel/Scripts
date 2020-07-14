

<#
.SYNOPSIS
  This PowerShell script will get your current credentials and save as a credential XML file.
  

.DESCRIPTION
  This PowerShell script will get your current credentials and save as a credential XML file.

.INPUTS DomainUsername

.USAGE
.\Get-UserCredential.ps1 -DomainuserName " MY_DOMAIN\MYID" -CredPath C:\Temp\SecureCredentials.xml
		
.NOTES
  Script Name:    Get-UserCredential.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  11/18/2016
  Purpose/Change: Initial script development
  
.EXAMPLE
.\Get-UserCredential.ps1 -DomainuserName "MY_DOMAIN\MYID" -CredPath C:\Temp\SecureCredentials.xml

#>

param(
$domainusername,
$credpath,
[switch]$Help
)
$HelpText = @"

    Get-UserCredential
    Usage:
    Get-UserCredential -DomainUsername " MY_DOMAIN\MYID"

    If a credential is stored in $CredPath, it will be used.
    If no credential is found, Export-Credential will start and offer to
    Store a credential at the location specified.

"@

# Get Credentials:
$DomainUsername=$domainusername
$CredPath=$credpath
$cred = get-credential $DomainUsername | EXPORT-CLIXML $CredPath
