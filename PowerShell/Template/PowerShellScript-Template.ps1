
<#
.SYNOPSIS
  <Overview of script>
  
.DESCRIPTION
  <Brief description of script>
  
.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
	
.INPUTS
  <Inputs if any, otherwise state None>
  
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
  
.NOTES
  Script Name: PowerShellScript-Template.ps1
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
param(
[Parameter(Mandatory=$true)]
[string]$Parameter1,
[Parameter(Mandatory=$true)]
[string]$Parameter2,
[Parameter(Mandatory=$true)]
[string]$Parameter3
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
New-PSDrive -Name X -PSProvider FileSystem -Root C:\Users\rknechtel\Data\Documents\RICHDOCS\Programming\Scripts\PowerShell
Set-Location X:
Import-module X:\Functions\Write-Log.psm1 -Force

$global:ReturnCodeMsg = "Completed Successfully"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\Temp" # Change to where you want to Log to
$sLogName = "<script_name>.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

Write-Host "Log File is $sLogFile;
Write-Log -Message "Log File is -Path $sLogFile; 


#-----------------------------------------------------------[Functions]------------------------------------------------------------

<#
# Example function template
Function <FunctionName>{
  Param()
  
  Begin{
    Write-Log -Message "<description of what is going on>..." -Path $sLogFile -Level Info;
  }
  
  Process{
    Try{
      #<code goes here>

    }
    
    Catch{
      Write-Log -Message "<Error Message>....." -Path $sLogFile -Level Error;
      Break
    }
  }
  
  End{
    If($?){
      Write-Log -Message "<Function Nam> Completed Successfully.." -Path $sLogFile -Level Info;
      Write-Log -Message " " -Path $sLogFile -Level Info;
    }
  }
}
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


#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting <SCRIPT NAME> script.";
Write-Log -Message "********************************" -Path $sLogFile -Level Info;
Write-Log -Message "Starting <SCRIPT NAME> script." -Path $sLogFile -Level Info; 

try 
{
  # Try to send the Email:
  Write-Log -Message "DOING SOMETHING" -Path $sLogFile -Level Info;
  
  # Do Script stuff here
  
  Write-Log -Message "FINISHED DONIG SOMETHING" -Path $sLogFile -Level Info;
}  
catch
{
  # catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Log -Message "Exception caught in <SCRIPT NAME>: $ErrorMessage" -Path $sLogFile -Level Error;
}
finally
{
  Write-Host "Removing mapped Drive X";
  Write-Log -Message "Removing mapped Drive X" -Path $sLogFile -Level Info;
  Remove-PSDrive-name X
  
  # Retrun to the calling location
  ReturnToCallingLocation

  Write-Host "Finished running <SCRIPT NAME> script.";
  Write-Log -Message "Finished running <SCRIPT NAME> script." -Path $sLogFile -Level Info; 
  Write-Log -Message "********************************" -Path $sLogFile -Level Info;

  # Example setting return code/message
  $global:ReturnCodeMsg="There was an Error in <SCRIPT NAME>."
}

# Some Value or Variable
return $ReturnCodeMsg
