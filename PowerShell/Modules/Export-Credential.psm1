<#
.SYNOPSIS
  This PowerShell script module exports credentials.
  

.DESCRIPTION
  This script module export a users credentials to an XML file for later use
  in other PowerShell scripts.
  
.USAGE
 Export-Credential $CredentialObject $FileToSaveTo
		
.NOTES
  Script Name:    Export-Credential.psm1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  11/18/2016
  Purpose/Change: Initial script development
  
#>

function Export-Credential($cred, $path) {
      $cred = $cred | Select-Object *
      $cred.password = $cred.Password | ConvertFrom-SecureString
      $cred | Export-Clixml $path
}