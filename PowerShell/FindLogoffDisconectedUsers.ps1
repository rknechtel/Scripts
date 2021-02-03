
<#
.SYNOPSIS
  Force log off's users who are disconnected on a server.
  
.DESCRIPTION
  Force log off's users who are disconnected on a server.
  
.PARAMETER ServerName
  The Server Name of the server to force log off disconnected Users.

.INPUTS
  None
  
.OUTPUTS
  None
  
.NOTES
  Script Name: FindLogoffDisconectedUsers.ps1.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  02/02/2021
  Purpose/Change: Initial script development
  
  Requires ActiveDirectory Module to be installed:
  https://4sysops.com/wiki/how-to-install-the-powershell-active-directory-module/
  From Admin PowerShell:

.LICENSE
 This script is in the public domain, free from copyrights or restrictions.

  
.EXAMPLE
  .\FindLogoffDisconectedUsers.ps1 MYSERVERNAME
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
param(
[Parameter(Mandatory=$true)]
[string]$ServerName
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
Import-Module PSLogging

<#
 Example (Levels: Fatal, Error, Warn, Info):
 Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
#>

# Import AD Module
Import-Module ActiveDirectory

# Import Loging Module
Import-module D:\Scripts\Write-Log.psm1 -Force

$global:ReturnCodeMsg = "Completed Successfully"

$DisconnectedUsers=$false

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "D:\Temp" # Change to where you want to Log to
$sLogName = "FindLogoffDisconectedUsers.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

Write-Host "Log File is $sLogFile;
Write-Log -Message "Log File is -Path $sLogFile; 


#-----------------------------------------------------------[Functions]------------------------------------------------------------

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


#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting FindLogoffDisconectedUsers script.";
Write-Log -Message "********************************" -Path $sLogFile -Level Info;
Write-Log -Message "Starting FindLogoffDisconectedUsers script." -Path $sLogFile -Level Info; 

try 
{
  # Starting Script run:
  Write-Host "Getting disconnected users on $ServerName and force logging them off."
  Write-Log -Message "Getting disconnected users on $ServerName and force logging them off." -Path $sLogFile -Level Info;
  
  # Do Script stuff here
  quser /server:$ServerName | ? { $_ -match "Disc" }|foreach {
    $Session = ($_ -split ' +')[2]
    $user = ($_ -split ' +')[1]
    $idletime= ($_ -split ' +')[4]

    # Get Users First and Last Name:
    $usesrsname = Get-ADUser -Identity $user -Properties *
    $fname = $usesrsname.GivenName
    $lname = $usesrsname.Surname
    Write-Host "Logged in user is: $fname $lname"
    Write-Log -Message "Logged in user is: $fname $lname." -Path $sLogFile -Level Info;

    $DisconnectedUsers=$true

    Write-Host "Force Logging off user $user ($fname $lname) with session id $Session who is idle for $idletime."
    Write-Log -Message "Force Logging off user $user with session id $Session who is idle for $idletime." -Path $sLogFile -Level Info;
    logoff $Session /server:$ServerName
  }
  
  if($DisconnectedUsers -eq $true)
  { 
    Write-Host "We had disconnected users on $ServerName and forced logged them off."
    Write-Log -Message "We had disconnected users on $ServerName and forced logged them off." -Path $sLogFile -Level Info;
  }
  else
  {
    Write-Host "We did not have disconnected users on $ServerName."
    Write-Log -Message "We did not have disconnected users on $ServerName." -Path $sLogFile -Level Info;
  }
  
  Write-Host "Finished getting disconnected users on $ServerName and force logging them off."
  Write-Log -Message "Finished getting disconnected users on $ServerName and force logging them off." -Path $sLogFile -Level Info;
}  
catch
{
  # catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Host "Exception caught in FindLogoffDisconectedUsers: $ErrorMessage"
  Write-Log -Message "Exception caught in FindLogoffDisconectedUsers: $ErrorMessage" -Path $sLogFile -Level Error;

  $global:ReturnCodeMsg="There was an Error in FindLogoffDisconectedUsers."
}
finally
{ 
  # Retrun to the calling location
  ReturnToCallingLocation

  Write-Host "Finished running FindLogoffDisconectedUsers script.";
  Write-Log -Message "Finished running FindLogoffDisconectedUsers script." -Path $sLogFile -Level Info; 
  Write-Log -Message "********************************" -Path $sLogFile -Level Info;

}

# Some Value or Variable
return $ReturnCodeMsg