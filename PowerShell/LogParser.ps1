

<#
.SYNOPSIS
  Generic Log File Parser
  
.DESCRIPTION
  This script will allow you to look for text in log files.
  
.PARAMETER NONE
	
.INPUTS
  pLogpath
  pLogFileName
  pStringToFind

.OUTPUTS
  ReturnCodeMsg - Returns a code and or message to the caller.
  
.NOTES
  Script Name: LogParser.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  09/17/2017
  Purpose/Change: Initial script development
  
.EXAMPLE
  .\LogParser.ps1 '\\MyServer\d$\opt\MyApplicationl\log' 'app.log' 'ERROR'

#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
param(
[Parameter(Mandatory=$true)]
[string]$pLogpath,
[Parameter(Mandatory=$true)]
[string]$pLogFileName,
[Parameter(Mandatory=$true)]
[string]$pStringToFind
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

#Import Modules & Snap-ins
Import-Module PSLogging

<#
 Example (Levels: Fatal, Error, Warn, Info):
 Write-Log -Message 'Folder does not exist.' -Path C:\Logs\Script.log -Level Error
#>
New-PSDrive -Name X -PSProvider FileSystem -Root C:\Scripts\PowerShell\Functions
Set-Location X:
Import-module X:\Write-Log.psm1 -Force

<#
  Map Drive to path of Log file
  Example:
  \\MyServer\d$\opt\MyApplicationl\log
#>
New-PSDrive -Name Z -PSProvider FileSystem -Root $pLogpath
Set-Location Z:

# Get calling directory - to go back to
$CallingLocation = Convert-Path .

$Seperator = "**********************************************************************"

$global:ReturnCodeMsg = "Completed Successfully"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\Temp" # Change to where you want to Log to
$sLogName = "LogParser.log"
$sLogFile = Join-Path -Path $pLogpath -ChildPath $sLogName

Write-Host "Log File is $sLogFile;
Write-Log -Message "Log File is -Path $sLogFile; 


#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function FindError
{
  Param()
  
  Begin
  {
    Write-Log -Message "Searching for $pStringToFind in $pLogpath\$pLogFileName." -Path $sLogFile -Level Info;
  }
  
  Process
  {
    Try
    {
      $SelectedText = Select-String -Path Z:\$pLogFileName -pattern $pStringToFind 
      #write-host SelectedText = $SelectedText
      If ([string]::IsNullOrWhiteSpace($SelectedText))
      {
          write-host "$pLogpath\$pLogFileName does not contain $pStringToFind"
          Write-Log -Message "$pLogpath\$pLogFileName does not contain $pStringToFind." -Path $sLogFile -Level Error;
          $global:ReturnCodeMsg="$pStringToFind was not found in $pLogpath\$pLogFileName"
      }
      Else
      {
          write-host "$pLogpath\$pLogFileName contains $pStringToFind - writing to results to $pLogpath\errorsfound.log."
          Write-Log -Message "$pLogpath\$pLogFileName contains $pStringToFind - writing to results to $pLogpath\errorsfound.log." -Path $sLogFile -Level Info;
          $global:ReturnCodeMsg="$pStringToFind was found in $pLogpath\$pLogFileName"
          $SelectedText>>$sLogPath\errorsfound.log
      }

    }
    
    Catch
    {
      Write-Log -Message "FindError was unable to find $pStringToFind in $pLogpath\$pLogFileName." -Path $sLogFile -Level Error;
      Break
    }
  }
  
  End
  {
    If($?)
    {
      Write-Log -Message "FindError Completed Successfully." -Path $sLogFile -Level Info;
      Write-Log -Message " " -Path $sLogFile -Level Info;
    }
  }
}

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

Write-Host "Starting LogParser.ps1 script.";
Write-Log -Message $Seperator -Path $sLogFile -Level Info;
Write-Log -Message "Starting LogParser.ps1 script." -Path $sLogFile -Level Info; 

try 
{
  # Try to send the Email:
  Write-Log -Message "Looking for Error" -Path $sLogFile -Level Info;
  
  # Do Script stuff here
  FindError
  
  Write-Log -Message "Finished Looking for Error" -Path $sLogFile -Level Info;
}  
catch
{
  # catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Log -Message "Exception caught in LogParser.ps1: $ErrorMessage" -Path $sLogFile -Level Error;
}
finally
{
  Write-Host "Removing mapped Drive X";
  Write-Log -Message "Removing mapped Drive X" -Path $sLogFile -Level Info;
  Remove-PSDrive-name X
  
  Write-Host "Removing mapped Drive Z";
  Write-Log -Message "Removing mapped Drive Z" -Path $sLogFile -Level Info;
  Remove-PSDrive-name Z

  # Retrun to the calling location
  ReturnToCallingLocation

  Write-Host "Finished running LogParser.ps1 script.";
  Write-Log -Message "Finished running LogParser.ps1 script." -Path $sLogFile -Level Info; 
  Write-Log -Message $Seperator -Path $sLogFile -Level Info; 

$global:ReturnCodeMsg="Script LogParser.ps1 had an error - see log file located in $sLogFile."
}

# Some Value or Variable
return $ReturnCodeMsg

