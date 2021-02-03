
<#
	.SYNOPSIS
  This script will set Share permissions for a given AppSrv instance Windows Shares.
  
.DESCRIPTION
  This script will set the following authorities:
   Read to AppSrv instance log directory (Example: \\server\WF10AppSv01_log (D:\opt\wildfly-10.1.0.Final\AppSrv01\log))
   Read to AppSrv instance ApplicationSonfigurations directory (Example: \\server\WF10ApplicationConfigurations1 (D:\opt\wildfly-10.1.0.Final\AppSrv01\ApplicationConfigurations))

   The following permissions will be set:
   <SERVER>\Admiistrators - Full Control
   DOMAIN\ServerAdmin-Wildfly  - Full Control
   DOMAIN\WildflyLogsDev - Read
   DOMAIN\WildflyLogsTest - Read
   DOMAIN\WildflyLogsProd - Read

  
.PARAMETER ServerName
           Server Name/DNS Alias (prefered).

.PARAMETER AppSrvNumber
           AppSrv Number (Example: 01).

.PARAMETER WFVersion
           Wildfly Version (Example: 10).

.PARAMETER ExtWF
           ExtWF (Example: $True).
		   
.INPUTS ServerName
.INPUTS AppSrvNumber
.INPUTS WFVersion
.INPUTS ExtWF
  
.OUTPUTS
  None
  
.NOTES
  Script Name:    SetSharePermissions.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  10/02/2018
  Purpose/Change: Initial script development

.LICENSE
 This script is in the public domain, free from copyrights or restrictions.

.EXAMPLE
   From Command line:
   %SCRIPTPATH%\SetSharePermissions.ps1 -ServerName "wildflydev" -AppSrvNumber "01" -WFVersion "10"

  Call From DOS Batch:
  PowerShell -ExecutionPolicy Bypass -Command %SCRIPTPATH%\SetSharePermissions.ps1 -ServerName "wildflydev" -AppSrvNumber "01" -WFVersion "10" -ExtWF $True

#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

param
(
  [Parameter(Mandatory=$true)]
  [string]$ServerName,    # Example: wildflydev
  [Parameter(Mandatory=$true)]
  [string]$AppSrvNumber,  # Example: 01
  [Parameter(Mandatory=$true)]
  [string]$WFVersion,     # Example: 10
  [Parameter(Mandatory=$false)]
  [bool]$ExtWF = $false         # Example: $True 
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent

<#
 Example (Levels: Fatal, Error, Warn, Info):
 Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
#>
Import-module D:\PowerShell\Functions\Write-Log.psm1 -Force
Import-module $PSScriptRoot\PSSQLite\PSSQLite.psm1 -Force


# Import the SMB Modules
Import-Module Smb*

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "D:\Temp"
$sLogName = "SetSharePermisisons.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

# Get current directory - to go back to
$CurrentLocation = Convert-Path .

# Get Wildfly Path
$WFVer = "WILDFLY" + $WFVersion + "_HOME"
$WFPath = [Environment]::GetEnvironmentVariable($WFVer)

# Middleware Database (SQLite)
$MiddlewareDB = $WFPath + "\usrbin\Database\MiddlewareDB.s3db"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

# Usage
function Usage
{
  Write-Log -Message "No Parameters passed to SetSharePermisisons script." -Path $sLogFile -Level Info; 
  Write-Log -Message "                                             " -Path $sLogFile -Level Info;
  Write-Host "[USAGE]: SetSharePermisisons.ps1 arg1 arg2 arg3 arg4"
  Write-Host "arg1 = Server Name (Example:wildflydev)"
  Write-Host "arg2 = AppSrv Number (Example: 01)"
  Write-Host "arg3 = Wildfly Version (Example: 10)"
  Write-Host "arg4 = (Optional) External (Must be lowercase: yes)"
  Write-Log -Message "                                             " -Path $sLogFile -Level Info;
  
  return
}


<#
  Function: ReturnToCallingLocation
  Description: This will return the script to the calling location
  Parameters: None
  Example Call: ReturnToCallingLocation
#>
function ReturnToCallingLocation
{
  Begin 
  { 
    # Set VerbosePreference to Continue so that verbose messages are displayed. 
    $VerbosePreference = 'Continue' 
  } 
  Process 
  { 
    # Go back to calling script directory
    Write-Host "Returning to Calling Scripts Directory = $PSScriptRoot"
    Write-Log -Message "Returning to Calling Scripts Directory = $PSScriptRoot" -Path $sLogFile -Level Info;
    Write-Log -Message "                                             " -Path $sLogFile -Level Info;
    Set-Location -Path $PSScriptRoot
    Set-Location -Path $PSScriptRoot.PSDrive.Name
    #return
  }
  End 
  { 
    return
  }
}

<#
  Function: CreateShare
  Description: This will Create a Windows Network Share using the parameters passed in.
  Parameters: Share Name
              Local Directory
  Example Call: CreateShare MyShare C:\work\mydirectory
#>
function CreateShare
{
  [CmdletBinding()] 
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("ShareName")] 
    [string]$Share,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("ShareDirectory")] 
    [string]$Path
  )

  Begin 
  { 
    # Set VerbosePreference to Continue so that verbose messages are displayed. 
    $VerbosePreference = 'Continue' 
  } 
  Process 
  { 
    Write-Host "Creating new SMB Share";
    Write-Log -Message "MCreating Share: $Share mapped to $Path" -Path $sLogFile -Level Info;
    Write-Log -Message "                                             " -Path $sLogFile -Level Info;

    # Create new file share
    New-SmbShare –Name $Share –Path $Path

  }
  End 
  { 
    return
  }
}


<#
  Function: RemoveMappedDrive
  Description: This will remove a mapped drive that is passed in.
  Parameters: Drive Letter
  Example Call: RemoveMappedDrive X

#>
function RemoveMappedDrive
{
  [CmdletBinding()] 
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("DriveLetter")] 
    [string]$Drive
  )

  Begin 
  { 
    # Set VerbosePreference to Continue so that verbose messages are displayed. 
    $VerbosePreference = 'Continue' 
  } 
  Process 
  { 
    Write-Host "Removing Mapped Drive $Drive";
    Write-Log -Message "Removing mapped Drive $Drive" -Path $sLogFile -Level Info;
    Write-Log -Message "                                             " -Path $sLogFile -Level Info;
    Remove-PSDrive-name $Drive
    #return
  }
  End 
  { 
    return
  }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting SetSharePermisisons script.";
Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
Write-Log -Message "Starting SetSharePermisisons script." -Path $sLogFile -Level Info; 
Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;

# Check if we got mandatory parameters:
if($ServerName -eq "" -and $AppSrvNumber -eq "" -and $WFVersion -eq "")
{
  Write-Host "Calling Usage"
  Usage
  Write-Host "calling ReturnToCallingLocation"
  ReturnToCallingLocation


  # Exit Script
  exit
  #Exit-PSHostProcess
}


Write-Host "Passed Parameters: ServerName = $ServerName, AppSrvNumber = $AppSrvNumber, WFVersion = $WFVersion";
Write-Log -Message "Passed Parameters: ServerName = $ServerName, AppSrvNumber = $AppSrvNumber, WFVersion = $WFVersion" -Path $sLogFile -Level Info;

  #--------------------------------------------------------------------------------------------------------
  # Set permissions on Windows Shares for:
  # Wildfly log directories
  # Wildfly AppSrv ApplicationConfigurations directories
  #
  # Log Shares example:
  # \\wildflydev\WF10AppSrv01_log
  #
  # ApplicationConfigurations Shares Example:
  # \\wildflydev\WF10ApplicationConfigurations1
  #
  # Permissions:
  # <SERVER>\Admiistrators - Full Control
  # DOMAIN\ServerAdmin-Wildfly  - Full Control
  # DOMAIN\WildflyLogsDev - Read
  # DOMAIN\WildflyLogsTest - Read
  # DOMAIN\WildflyLogsProd - Read
  #
  #--------------------------------------------------------------------------------------------------------

try
{

  # ********************************************
  # Set permissions for Log Share:
  # ********************************************
  Write-Host "Setting permissions for Log directory share.";
  Write-Log -Message "Setting permissions for Log directory share." -Path $sLogFile -Level Info;

  if ($ExtWF)
  {
    $WFLog='WF' + $WFVersion + 'ExtAppSrv' + $AppSrvNumber + '_log'
  }
  else
  {
    $WFLog='WF' + $WFVersion + 'AppSrv' + $AppSrvNumber + '_log'
  }
  
  Write-Host "Wildfly Log share path = $WFLog";
  Write-Log -Message "Wildfly Log share path = $WFLog" -Path $sLogFile -Level Info;
  

  # *************************************************
  # 1) Get data from SQLite Database:
  #
  # Check both DNS Alias and Server Name to catch either one.
  $SQLQuery = "Select Servers.ServerName, Shares.ShareName,Shares.ShareGroupForAccess,Shares.SharePermissions from Shares inner join Servers on Servers.ID = Shares.Server_ID where (Servers.DNSAlias='$ServerName' or Servers.ServerName='$ServerName') and Shares.ShareName='$WFLog'"
  Write-Host "SQLQuery = $SQLQuery"
  Write-Log -Message "SQLQuery = $SQLQuery" -Path $sLogFile -Level Info;
  
  # Invoke SQLite Query
  Write-Host "MiddlewareDB = $MiddlewareDB"
  Write-Log -Message "MiddlewareDB = $MiddlewareDB" -Path $sLogFile -Level Info;
  
  Write-Log -Message "Running SQLQuery." -Path $sLogFile -Level Info;
  $Results = Invoke-SqliteQuery -Query $SQLQuery -DataSource $MiddlewareDB
  Write-Host "SQLQuery Results = $Results"
  Write-Log -Message "SQLQuery Results = $Results" -Path $sLogFile -Level Info;
  
  # *************************************************
  # 2) Iterate over log share records
  # Loop over results and set Permissions
  [bool]$FirstTime = $true
  foreach ($Result in $Results)
  {
    #Write-Host "Result = $Result"
      
    # Get Group to assign permissions for:
    $Group = $Result.ShareGroupForAccess
    # Get Permisssions to assign Group:
    $Rights = $Result.SharePermissions
    # Get Share Name:
    $ShareName = $Result.ShareName

    # Directory: Read from MiddlewareDB ('\\' + $ServerName + '\' + Shares.ShareName)
    #$Share = "\\" + $Result.ServerName + "\" + $ShareName
    #Write-Host "Share = $Share"

    # Directory to map Log Directory share to:
    $ShareDirectory = $WFPath + "\AppSrv" + $AppSrvNumber + "\log"

    if ($FirstTime -eq $true)
    {
      # *************************************************
      # 3) Create Log Directory Share:
      CreateShare $Result.ShareName $ShareDirectory
   
      # *************************************************
      # 4) Remove Everyone access from Share
	    Write-Host "Revoking access for Everyone to share $ShareName"
      Revoke-SmbShareAccess –Name $ShareName –AccountName "Everyone" -Force
    }

    # *************************************************
    # Grant access for Log
    Write-Host "Granting access to share $ShareName for $Group"
    Write-Host "Running Grant-SmbShareAccess –Name $ShareName –AccountName $Group –AccessRight $Rights -Force"
    Grant-SmbShareAccess –Name $ShareName –AccountName $Group –AccessRight $Rights -Force
   
    # Getting ready to go next time around
    $FirstTime = $false
  }

  # Go back to original directory
  Set-Location -Path $CurrentLocation


 
  # ******************************************************
  # Set permissions for ApplicationConfigurations Share:
  # ******************************************************
  
  # Get current directory - to go back to
  $CurrentLocation = Convert-Path .

  Write-Host "Setting permissions for ApplicationConfigurations share.";
  Write-Log -Message "Setting permissions for ApplicationConfigurations share." -Path $sLogFile -Level Info;
  
  if ($ExtWF)
  {
    $WFac='WF' + $WFVersion + 'ExtApplicationConfigurations'
  }
  else
  {
    $WFac='WF' + $WFVersion + 'ApplicationConfigurations'
  }
  
  $subst=$AppSrvNumber.Substring(0,1)
  IF ($subst -eq "0")
  {
    $subst=$AppSrvNumber.Substring(1,1)
    $WFac=$WFac + $subst
  }
  else
  {
    $WFac=$WFac + $AppSrvNumber
  }
  
  Write-Host "Wildfly ApplicationConfiguration share path = $WFac";
  Write-Log -Message "Wildfly ApplicationConfiguration share path = $WFac" -Path $sLogFile -Level Info;  

  # Check both DNS Alias and Server Name to catch either one.
  $SQLQuery = "Select Servers.ServerName, Shares.ShareName,Shares.ShareGroupForAccess,Shares.SharePermissions from Shares inner join Servers on Servers.ID = Shares.Server_ID where (Servers.DNSAlias='$ServerName' or Servers.ServerName='$ServerName') and Shares.ShareName='$WFac'"
  Write-Host "SQLQuery = " $SQLQuery
  # Invoke SQLite Query
  $Results = Invoke-SqliteQuery -Query $SQLQuery -DataSource $MiddlewareDB
  Write-Host "Results = " $Results
  
  # **********************************************************
  # 2) Iterate over ApplicationConfigurations share records
  # Loop over results and set Permissions

  [bool]$FirstTime = $true
  foreach ($Result in $Results)
  {
    #Write-Host "Result = $Result"
    
    # Get Group to assign permissions for:
    $Group = $Result.ShareGroupForAccess
    # Get Permisssions to assign Group:
    $Rights = $Result.SharePermissions
    # Get Share Name:
    $ShareName = $Result.ShareName    

    # Directory: Read from MiddlewareDB ('\\' + $ServerName + '\' + Shares.ShareName)
    #$Share = "\\" + $Result.ServerName + "\" + $ShareName
    #Write-Host "Share = $Share"
   
    # **********************************************************************
    # Note: Only need to create share once and revoke Everyone access once
    # **********************************************************************
    
    # Directory to map Log Directory share to:
    $ShareDirectory = $WFPath + "\AppSrv" + $AppSrvNumber + "\ApplicationConfigurations"

    if ($FirstTime -eq $true)
    {
      # *************************************************
      # 3) Create ApplicationConfigurations Directory Share:
      CreateShare $ShareName $ShareDirectory
   
      # *************************************************
      # 4) Remove Everyone access from Share
	    Write-Host "Revoking access for Everyone to share $ShareName"
      #$Everyone = $Result.ServerName + "\Everyone"
      Revoke-SmbShareAccess –Name $ShareName –AccountName "Everyone" -Force
    }

    # *************************************************
    # Grant access for ApplicationConfigurations
	  Write-Host "Granting access to share $ShareName for $Group"
    Grant-SmbShareAccess –Name $ShareName –AccountName $Group –AccessRight $Rights -Force
   
    # Getting ready to go next time around
    $FirstTime = $false
  }
  
  # Go back to original directory
  Set-Location -Path $CurrentLocation

}
catch
{
    Write-Host "Danger! Danger! Will Robinson! We had an Error in SetSharePermissions.ps1!"
    Write-Log -Message "Exception caught in SetSharePermissions.ps1: Danger! Danger! Will Robinson! We had an Error in SetSharePermissions.ps1! - Error was: $_.Message" -Path $sLogFile -Level Error;
}
finally
{
  RemoveMappedDrive -Drive X
  ReturnToCallingLocation

  Write-Host "Finished SetSharePermissions.ps1.";
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;
  Write-Log -Message "Finished SetSharePermissions.ps1." -Path $sLogFile -Level Info;
  Write-Log -Message "*********************************************" -Path $sLogFile -Level Info;

}