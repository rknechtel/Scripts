<#
	.SYNOPSIS
  This script will setup folder/file permissions for a given AppSrv instance service account.
  
.DESCRIPTION
  This script will set the following authorities:
   Read/Write/Execute to AppSrv instance directory (Example: %WILDFLY10_HOME%\AppSv01 (D:\opt\wildfly-10.1.0.Final\AppSrv01))
   No access to All other AppSrv directories (Example: AppSrv02,AppSrv03,AppSrv04,AppSrv05)
   Read/Execute for root Widfly directory (Example: %WILDFLY10_HOME% (D:\opt\wildfly-10.1.0.Final))
   Read/Write to D:\Temp
   No access to Root D:\ Drive
   No access to Root C:\ Drive
  
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

.EXAMPLE
   For Local Server Service Account:
  .\SetServiceAccountPermissions.ps1 -AppSrvInstance "AppSrv01" -ServiceAccount "LOCALSYSTEM\svc_devAppSrv01"
  For AD Service Account:
  .\SetServiceAccountPermissions.ps1 -AppSrvInstance "AppSrv01" -ServiceAccount "DOMAIN\svc_DevAppSrv01"

  Call From DOS Batch:
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetServiceAccountPermissions.ps1 -AppSrvInstance "AppSrv01" -ServiceAccount "LOCALSYSTEM\svc_devAppSrv01"

#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

param
(
  [Parameter(Mandatory=$true)]
  [string]$AppSrvInstance,  # Example: AppSrv01
  [Parameter(Mandatory=$true)]
  [string]$ServiceAccount   # Example: DOMAIN\svc_DevAppSrv01
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

<#
 Example (Levels: Fatal, Error, Warn, Info):
 Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
#>
New-PSDrive -Name X -PSProvider FileSystem -Root \\mydirectory\Scripts\Powershell
Set-Location X:
Import-module X:\Functions\Write-Log.psm1 -Force

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "D:\Temp"
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
  # Set Read/Execute for root Widfly directory (Example: %WILDFLY10_HOME% (D:\opt\wildfly-10.1.0.Final))
  # Set this first - then set permissions for specific AppSrv instance.

  Write-Host "Setting Read/Execute permissions for $ServiceAccount on root Widfly directory.";
  Write-Log -Message "Setting Read/Execute permissions for $ServiceAccount on root Widfly directory." -Path $sLogFile -Level Info;

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
  # Note: MUST SET high level root Widfly directory FIRST! (See above)
 
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

  $Rights = "Read, Write, ReadAndExecute, ListDirectory"
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

  #--------------------------------------------------------------------------------------------------------
  # NOTE: may not need to do the last two items below:

  #--------------------------------------------------------------------------------------------------------
  # Set No access to All other AppSrv directories (Example: AppSrv02,AppSrv03,AppSrv04,AppSrv05)
  # See: Set No access to C:\ and D:\ (Below)


  #--------------------------------------------------------------------------------------------------------
  # Set No access to C:\ and D:\
  # Notes:
  #
  # Test to Deny Access to Root of D:\ :
  #
  # $ServiceAccount = "LOCALSYSTEM\svc_devAppSrv01"
  # $Directory = "D:\"
  # $acl = Get-Acl $Directory
  # $Rights = "Read, Write, ReadAndExecute, ListDirectory, Modify"
  # $Permission = $ServiceAccount, $Rights, $InheritanceNoneFlag, $PropagationNoneFlag, $AccessDenyType
  # $denyrule = New-Object System.Security.AccessControl.FileSystemAccessRule($Permission)
  # $acl.AddAccessRule($denyrule)
  # set-acl $Directory $acl
  #
  # Get-Acl D:\ | Format-List
  #
  # To Remove Block:
  #
  # $acl.RemoveAccessRule($denyrule)
  # set-acl $Directory $acl
  #
  # Get-Acl D:\ | Format-List
  #
  #--------------------------------------------------------------------------------------------------------


}
catch
{
    Write-Host "Danger! Danger! Will Robinson! We had an Error in ServiceAccountPermissions.ps1!"
    Write-Log -Message "Exception caught in ServiceAccountPermissions.ps1: Danger! Danger! Will Robinson! We had an Error in ServiceAccountPermissions.ps1!" -Path $sLogFile -Level Error;
}
finally
{
  Write-Host "Finished setting permissions for $ServiceAccount.";
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
  Write-Log -Message "Finished setting permissions for $ServiceAccount." -Path $sLogFile -Level Info;
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
}
