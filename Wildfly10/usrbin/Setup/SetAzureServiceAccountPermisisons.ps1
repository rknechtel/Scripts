
<#
.SYNOPSIS
  This script will setup folder/file permissions for a given AppSrv instance service account.
  
.DESCRIPTION
  This script will set the following authorities:
  Read/Write/Execute to D:\azure_agent
   Read/Execute to %JBOSS_HOME%\bin
   Full Control to %JBOSS_HOME%\AppDeployments
                   %JBOSS_HOME%\AppSrvXX\ApplicationConfigurations
                   %JBOSS_HOME%\AppSrvXX\deploymentbackups
                   %JBOSS_HOME%\AppSrvXX\deployments
   Read/Write/Update/Delete to %JBOSS_HOME%\AppSrvXX\data\content
   Read/Write/Update to %JBOSS_HOME%\AppSrvXX\configuration\AppSrvXX-full.xml
  
.PARAMETER AppSrvInstance
           Wildfly AppSrv instance the service account is for.

.PARAMETER ServiceAccount
           Service Account for the Azure deployment account.
	
.INPUTS AppSrvInstance
.INPUTS ServiceAccount
  
.OUTPUTS
  None
  
.NOTES
  Script Name:    SetAzureServiceAccountPermisisons.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  09/10/2019
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
  .\SetAzureServiceAccountPermisisons.ps1 -AppSrvInstance "AppSrv01" -ServiceAccount "SERVER\svc_AzureDevDeployment"
  For AD Service Account:
  .\SetAzureServiceAccountPermisisons.ps1 -AppSrvInstance "AppSrv01" -ServiceAccount "DOMAIN\svc_AzureDevDeployment"

  Call From DOS Batch:
  PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\SetAzureServiceAccountPermisisons.ps1 -AppSrvInstance "AppSrv01" -ServiceAccount "SERVER\svc_AzureDevDeployment"

#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

param
(
  [Parameter(Mandatory=$true)]
  [string]$AppSrvInstance,  # Example: AppSrv01
  [Parameter(Mandatory=$true)]
  [string]$ServiceAccount   # Example: SERVER\svc_AzureDevDeployment OR DOMAIN\svc_AzureDevDeployment
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

<#
 Example (Levels: Fatal, Error, Warn, Info):
 Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
#>
Import-module D:\PowerShell\Functions\Write-Log.psm1 -Force

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "D:\Temp"
$sLogName = "SetAzureServiceAccountPermisisons.log"
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

# Root Wildfly Directory
# RSK 09/25/2019: Looks like can't set permissions via a Directory Junction
#$RootDir = "$env:JBOSS_HOME"
$RootDir="$env:WILDFLY10_HOME"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

# NONE

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting SetAzureServiceAccountPermisisons script.";
Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
Write-Log -Message "Starting SetAzureServiceAccountPermisisons script." -Path $sLogFile -Level Info; 
Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;

try
{
  #--------------------------------------------------------------------------------------------------------
  # Set Read/Execute to D:\azure_agent

  Write-Host "Setting Read/Write/Execute permissions for $ServiceAccount on D:\azure_agent.";
  Write-Log -Message "Setting Read/Write/Execute permissions for $ServiceAccount on D:\azure_agent." -Path $sLogFile -Level Info;

  $Rights = "Read, ReadAndExecute, ListDirectory, Write"
  $Permission = $ServiceAccount, $Rights, $InheritanceContainerObjectFlag, $PropagationNoneFlag, $AccessAllowType
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Permission
  
   # Set ACL on top level directory:
  $Directory = "D:\azure_agent"
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
  # Set Read/Execute to %JBOSS_HOME%\bin

  Write-Host "Setting Read/Execute permissions for $ServiceAccount on %JBOSS_HOME%\bin.";
  Write-Log -Message "Setting Read/Execute permissions for $ServiceAccount on %JBOSS_HOME%\bin." -Path $sLogFile -Level Info;

  $Rights = "Read, ReadAndExecute, ListDirectory"
  $Permission = $ServiceAccount, $Rights, $InheritanceContainerObjectFlag, $PropagationNoneFlag, $AccessAllowType
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Permission
  
   # Set ACL on top level directory:
  $Directory = "$RootDir\bin"
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
  # Set Full Control to:
  #                     %JBOSS_HOME%\AppDeployments
  #                     %JBOSS_HOME%\AppSrvXX\ApplicationConfigurations
  #                     %JBOSS_HOME%\AppSrvXX\deploymentbackups
  #                     %JBOSS_HOME%\AppSrvXX\deployments
 
  Write-Host "Setting Full Control permissions for $ServiceAccount on $RootDir\AppDeployments, $RootDir\$AppSrvInstance\deploymentbackups, $RootDir\$AppSrvInstance\deployments directories.";
  Write-Log -Message "Setting Full Control permissions for $ServiceAccount on $RootDir\AppDeployments, $RootDir\$AppSrvInstance\deploymentbackups, $RootDir\$AppSrvInstance\deployments directories." -Path $sLogFile -Level Info;

  $Rights = "FullControl"
  $Permission = $ServiceAccount, $Rights, $InheritanceContainerObjectFlag, $PropagationNoneFlag, $AccessAllowType
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Permission
 
  # Get current directory - to go back to
  $CurrentLocation = Convert-Path .

  # Set ACL on directories:
  $Directories = @("$RootDir\AppDeployments", "$RootDir\$AppSrvInstance\ApplicationConfigurations", "$RootDir\$AppSrvInstance\deploymentbackups", "$RootDir\$AppSrvInstance\deployments")
  
  for ($i=0; $i -lt $Directories.length; $i++) 
  {
    $Directory = $Directories[$i]
	$acl = Get-Acl $Directory
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

  # Go back to original directory
  Set-Location -Path $CurrentLocation


  #--------------------------------------------------------------------------------------------------------
  # Set Read/Write/Update/Delete for %JBOSS_HOME%\AppSrvXX\data\content

  Write-Host "Setting Read/Write/Delete permissions for $ServiceAccount on $RootDir\$AppSrvInstance\data\content.";
  Write-Log -Message "Setting Read/Write/Delete permissions for $ServiceAccount on $RootDir\$AppSrvInstance\data\content directory." -Path $sLogFile -Level Info;

  $Rights = "Modify"
  $Permission = $ServiceAccount, $Rights, $InheritanceContainerObjectFlag, $PropagationNoneFlag, $AccessAllowType
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $Permission

  # Set ACL on top level directory:
  $Directory = "$RootDir\$AppSrvInstance\data\content"
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
  # Set Read/Write/Update for %JBOSS_HOME%\AppSrvXX\configuration\AppSrvXX-full.xml
  
  Write-Host "Setting Read/Write/Update permissions for $ServiceAccount on $RootDir\$AppSrvInstance\configuration\$AppSrvInstance-full.xml.";
  Write-Log -Message "Setting Read/Write/Update permissions for $ServiceAccount on $RootDir\$AppSrvInstance\configuration\$AppSrvInstance-full.xml." -Path $sLogFile -Level Info;
  
  $FileToMod = "$RootDir\$AppSrvInstance\configuration\$AppSrvInstance-full.xml"
  $Rights = "Read, Write"
  $Permission = $ServiceAccount, $Rights, $AccessAllowType
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule  ($Permission)  

  $acl = Get-Acl $FileToMod
  $acl.SetAccessRule($AccessRule)
  $acl | Set-Acl $FileToMod

  # Tha', Tha', That's all Folks!
  
}
catch
{
    Write-Host "Danger! Danger! Will Robinson! We had an Error in SetAzureServiceAccountPermisisons.ps1!"
    Write-Log -Message "Exception caught in SetAzureServiceAccountPermisisons.ps1: Danger! Danger! Will Robinson! We had an Error in SetAzureServiceAccountPermisisons.ps1! - Error was: $_.Message" -Path $sLogFile -Level Error;
}
finally
{
  Write-Host "Finished setting permissions for $ServiceAccount.";
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
  Write-Log -Message "Finished setting permissions for $ServiceAccount." -Path $sLogFile -Level Info;
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
}

