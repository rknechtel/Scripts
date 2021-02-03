
<#
	.SYNOPSIS
  This script will setup folder/file permissions for a given AppSrv instance service account.
  
.DESCRIPTION
  This script will set the following authorities:
   Full Control to AppSrv instance directory (Example: %WILDFLY10_HOME%\AppSv01 (D:\opt\wildfly-10.1.0.Final\AppSrv01))
   Read/Execute to All other AppSrv directories (Example: AppSrv02,AppSrv03,AppSrv04,AppSrv05)
   Read/Execute for root Wildfly directory (Example: %WILDFLY10_HOME% (D:\opt\wildfly-10.1.0.Final))
   Read/Write/Execute/Modify to D:\Temp
   No access to Root D:\ Drive
   No access to Root C:\ Drive
   Removes Access from the Local SERVRENAME/Users group 
     - to rmeove "Special Permissions" (Create Files / Write Data & Create Folders / Append Data)
  
.PARAMETER AppSrvInstance
           Wildfly AppSrv instance the service account is for.

.PARAMETER ServiceAccount
           Service Account for the Wildfly AppSrv instance.
	
.INPUTS AppSrvInstance
.INPUTS ServiceAccount
  
.OUTPUTS
  None
  
.NOTES
  Script Name:    SetServiceAccountPermissions.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  05/17/2017
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
  .\SetServiceAccountPermissions.ps1 -AppSrvInstance "AppSrv01" -ServiceAccount "MYSERVERNAME\svc_devAppSrv01"
  For AD Service Account:
  .\SetServiceAccountPermissions.ps1 -AppSrvInstance "AppSrv01" -ServiceAccount "MYDOMAIN\svc_DevAppSrv01"

  Call From DOS Batch:
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetServiceAccountPermissions.ps1 -AppSrvInstance "AppSrv01" -ServiceAccount "MYSERVERNAME\svc_devAppSrv01"

#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

param
(
  [Parameter(Mandatory=$true)]
  [string]$AppSrvInstance,  # Example: AppSrv01
  [Parameter(Mandatory=$true)]
  [string]$ServiceAccount,   # Example: MYDOMAIN\svc_DevAppSrv01 or mc21dwin\svc_DevAppSrv01
  [Parameter(Mandatory=$true)]
  [string]$ServerName   # Example: MYSERVERNAME
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

<#
 Example (Levels: Fatal, Error, Warn, Info):
 Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
#>
New-PSDrive -Name X -PSProvider FileSystem -Root \\emcspb\IS\OperationalScripts\Powershell
Set-Location X:
Import-module X:\Functions\Write-Log.psm1 -Force

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\Temp"
$sLogName = "SetServiceAccountPermissions.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName


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

Write-Host "Starting SetServiceAccountPermissions script.";
Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
Write-Log -Message "Starting SetServiceAccountPermissions script." -Path $sLogFile -Level Info; 
Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;

try
{
  #--------------------------------------------------------------------------------------------------------
  # All Accounts don't have access to C:\ and D:\
  # Notes:
  # By default no local accounts created nor AD Accounts have any access to root of the D:\ or D:\Drive
  # unless they are in the local SERVERNAME/Users group - which has "Special Permissions"
  # (Create Files / Write Data & Create Folders / Append Data).
  # Removing users from the local SERVERNAME/Users group removes the "Special Permissions".
  #--------------------------------------------------------------------------------------------------------


  #--------------------------------------------------------------------------------------------------------
  # Remove user from Local SERVRENAME/Users group if not an AD Account.
  # Do this first - then set permissions for everything else.
  
  if($ServiceAccount.Contains($ServerName)) 
  {
    Write-Host "Removing user $ServiceAccount from Local $ServerName\Users group.";
    Write-Log -Message "Removing user $ServiceAccount from Local $ServerName\Users group." -Path $sLogFile -Level Info;
    Remove-LocalGroupMember -Group "Users" -Member "$ServiceAccount"
  }
  else 
  {
    Write-Host "User $ServiceAccount is not a local account and is not in the Local $ServerName\Users group.";
    Write-Log -Message "User $ServiceAccount is not a local account and is not in the Local $ServerName\Users group." -Path $sLogFile -Level Info;  
  }


  #--------------------------------------------------------------------------------------------------------
  # Set Read/Execute for root Wildfly directory (Example: %WILDFLY10_HOME% (D:\opt\wildfly-10.1.0.Final))
  # Set this first - then set permissions for specific AppSrv instance.

  Write-Host "Setting Read/Execute permissions for $ServiceAccount on root Wildfly directory.";
  Write-Log -Message "Setting Read/Execute permissions for $ServiceAccount on root Wildfly directory." -Path $sLogFile -Level Info;

  $Rights = "Read, ReadAndExecute, ListDirectory"
  $Permission = $ServiceAccount, $Rights, $InheritanceContainerObjectFlag, $PropagationNoneFlag, $AccessAllowType
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Permission
  
   # Set ACL on top level directory:
  $Directory = "$env:WILDFLY10_HOME"
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


  #--------------------------------------------------------------------------------------------------------
  # Set Read/Write/Execute to AppSrv instance directory (Example: %WILDFLY10_HOME%\AppSv01 (D:\opt\wildfly-10.1.0.Final\AppSrv01))
  # Note: MUST SET high level root Wildfly directory FIRST! (See above)
 
  Write-Host "Setting Read/Write/Execute permissions for $ServiceAccount on $AppSrvInstance instance directory.";
  Write-Log -Message "Setting Read/Write/Execute permissions for $ServiceAccount on $AppSrvInstance instance directory." -Path $sLogFile -Level Info;

  $Rights = "FullControl"
  $Permission = $ServiceAccount, $Rights, $InheritanceContainerObjectFlag, $PropagationNoneFlag, $AccessAllowType
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Permission
 
  # Get current directory - to go back to
  $CurrentLocation = Convert-Path .

  # Set ACL on top level directory:
  Set-Location -Path "$env:WILDFLY10_HOME"
  $Directory = "$AppSrvInstance"
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

  # Go back to original directory
  Set-Location -Path $CurrentLocation


  #--------------------------------------------------------------------------------------------------------
  # Set Read/Write/ListDirectory for D:\Temp

  Write-Host "Setting Read/Write/ListDirectory permissions for $ServiceAccount on D:\Temp directory.";
  Write-Log -Message "Setting Read/Write/ListDirectory permissions for $ServiceAccount on D:\Temp directory." -Path $sLogFile -Level Info;

  $Rights = "Modify" # Changed to allow delete of subfolders and files
  #$Rights = "Read, Write, ReadAndExecute, ListDirectory"
  $Permission = $ServiceAccount, $Rights, $InheritanceContainerObjectFlag, $PropagationNoneFlag, $AccessAllowType
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Permission

  # Set ACL on top level directory:
  $Directory = "D:\Temp"
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
    Write-Host "Danger! Danger! Will Robinson! We had an Error in ServiceAccountPermissions.ps1!"
    Write-Log -Message "Exception caught in ServiceAccountPermissions.ps1: Danger! Danger! Will Robinson! We had an Error in ServiceAccountPermissions.ps1! - Error was: $_.Message" -Path $sLogFile -Level Error;
}
finally
{
  Write-Host "Finished setting permissions for $ServiceAccount.";
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
  Write-Log -Message "Finished setting permissions for $ServiceAccount." -Path $sLogFile -Level Info;
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
}

