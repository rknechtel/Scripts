<#
	.SYNOPSIS
  This script will setup folder/file permissions for a given AppSrv instance service account.
  
.DESCRIPTION
  This script will set the following authorities:
   Full Control to D:\Opot\Wildfly
  
.PARAMETER NONE

.INPUTS NONE

  
.OUTPUTS
  None
  
.NOTES
  Script Name:    SetDOptWildflyPermisisons.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  07/08/2020
  Purpose/Change: Initial script development

  When Working with ACL's

  Available Rights:
    AppendData
    ChangePermissions
    CreateDirectories
    CreateFiles
    Delete
    DeleteSubdirectoriesAndFiles
    ExecuteFile
    FullControl
    ListDirectory
    Modify
    Read
    ReadAndExecute
    ReadAttributes
    ReadData
    ReadExtendedAttributes
    ReadPermissions
    Synchronize
    TakeOwnership
    Traverse
    Write
    WriteAttributes
    WriteData
    WriteExtendedAttributes

.LICENSE
 This script is in the public domain, free from copyrights or restrictions.

.EXAMPLE
   For Local Server Service Account:
  .\SetDOptWildflyPermisisons.ps1
  For AD Service Account:
  .\SetDOptWildflyPermisisons.ps1

  Call From DOS Batch:
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetDOptWildflyPermisisons.ps1

#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

#param
#(
#  [Parameter(Mandatory=$true)]
#  [string]$AppSrvInstance,  # Example: AppSrv01
#  [Parameter(Mandatory=$true)]
#  [string]$ServiceAccount   # Example: MyDomain\svc_DevAppSrv01
#)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

<#
 Example (Levels: Fatal, Error, Warn, Info):
 Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
#>

Import-module D:\Scripts\PowerShell\Functions\Write-Log.psm1 -Force

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "D:\Temp"
$sLogName = "SetDOptWildflyPermisisons.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

# Account - NOTE: Change to use parameter
$ServiceAccount = "DOMAIN\SERVICEACCOUNT"

# -------------------------------------------------------------------------------------------------------------------------------------------------------------
# Here's a table to help find the required flags for different Propagation/Inheritance permission combinations:
# ╔═════════════╦═════════════╦═══════════════════════════════╦════════════════════════╦══════════════════╦═══════════════════════╦═════════════╦═════════════╗
# ║             ║ folder only ║ folder, sub-folders and files ║ folder and sub-folders ║ folder and files ║ sub-folders and files ║ sub-folders ║    files    ║
# ╠═════════════╬═════════════╬═══════════════════════════════╬════════════════════════╬══════════════════╬═══════════════════════╬═════════════╬═════════════╣
# ║ Propagation ║ none        ║ none                          ║ none                   ║ none             ║ InheritOnly           ║ InheritOnly ║ InheritOnly ║
# ║ Inheritance ║ none        ║ Container|Object              ║ Container              ║ Object           ║ Container|Object      ║ Container   ║ Object      ║
# ╚═════════════╩═════════════╩═══════════════════════════════╩════════════════════════╩══════════════════╩═══════════════════════╩═════════════╩═════════════╝

# Setup Propagation Types
$PropagationInheritFlag = [System.Security.AccessControl.PropagationFlags]::InheritOnly
$PropagationNoneFlag = [System.Security.AccessControl.PropagationFlags]::None

# Setup Inheritance Types
$InheritanceContainerFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit
$InheritanceObjectFlag = [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$InheritanceContainerObjectFlag = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$InheritanceNoneFlag = [System.Security.AccessControl.InheritanceFlags]::None

# Setup Access Types
# Allow - is used to allow access to a secured object.
# Deny -  is used to deny access to a secured object.
$AccessAllowType = [System.Security.AccessControl.AccessControlType]::Allow
$AccessDenyType = [System.Security.AccessControl.AccessControlType]::Deny


#-----------------------------------------------------------[Functions]------------------------------------------------------------

# NONE

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting SetDOptWildflyPermisisons script.";
Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
Write-Log -Message "Starting SetDOptWildflyPermisisons script." -Path $sLogFile -Level Info; 
Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;

try
{
  #--------------------------------------------------------------------------------------------------------
  # Set RFullControl on D:\Opt\Wildfly Directory
 
  Write-Host "Setting Full Control permissions for D:\Opt\Wildfly directory.";
  Write-Log -Message "Setting Full Control permissions for D:\Opt\Wildfly directoryy." -Path $sLogFile -Level Info;

  $Rights = "FullControl"
  $Permission = $ServiceAccount, $Rights, $InheritanceContainerObjectFlag, $PropagationNoneFlag, $AccessAllowType
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Permission
  
   # Set ACL on top level directory:
  $Directory = "D:\opt\Wildfly"
  $acl = Get-Acl $Directory;
  $acl.SetAccessRule($AccessRule)
  $acl | Set-Acl $Directory

  # Apply ACL on items under top level directory
  $ChildItems = Get-ChildItem -path $Directory -Recurse | where {$_.PsIsContainer -eq $true}
  foreach ($ChildItem in $ChildItems)
  {
    # $ChildItem.fullname
    $acl = Get-Acl $ChildItem.Fullname
    $acl.SetAccessRule($AccessRule)
    $acl | Set-Acl $ChildItem.Fullname
  } 

}
catch
{
    Write-Host "Danger! Danger! Will Robinson! We had an Error in SetDOptWildflyPermisisons.ps1!"
    Write-Log -Message "Exception caught in SetDOptWildflyPermisisons.ps1: Danger! Danger! Will Robinson! We had an Error in SetDOptWildflyPermisisons.ps1! - Error was: $_.Message" -Path $sLogFile -Level Error;
}
finally
{
  Write-Host "Finished setting permissions on D:\OptWildfly.";
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
  Write-Log -Message "Finished setting permissions on D:\OptWildfly." -Path $sLogFile -Level Info;
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
}