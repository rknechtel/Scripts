

<# ************************************************************************
 Script: WinService.ps1
 Author: Richard Knechtel
 Date: 06/14/2016
 Description: This script will allow you to
              Stop/Start/Restart/Suspend/Resume Windows Services.
 
 Notes:
   Args format from a DOS Batch file:
   PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\WinService.ps1 stop "MyService" ServerName (e.g. MyerverName) remote
   Command Options:
     stop
     start
     restart
     suspend
     resume
   Service Locations:
     local
     remote
************************************************************************ #>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
Write-Host
Write-Host "Passed Arguments:" -foregroundcolor "Red" -backgroundcolor "White"
$args
Write-Host

# Set our Variables:
$servicecommand = $args[0]
$service = $args[1]
$server = $args[2]
$serviceloc = $args[3]

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Import Modules & Snap-ins
#Import-Module PSLogging

<#
 Example (Levels: Fatal, Error, Warn, Info):
 Write-Log -Message 'Folder does not exist.' -Path c:\Logs\Script.log -Level Error
#>
Import-module C:\Scripts\Modules\Write-Log.psm1 -Force

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#Log File Info
$sLogPath = "C:\temp" # Change to where you want to Log to
$sLogName = "WinService.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

Write-Host "Log File is $sLogFile;
Write-Log -Message "Log File is -Path $sLogFile; 

# Stop on first error:
$ErrorActionPreference = "Stop"

# Don't Try to do a remove session if New-PSSession fails.
$DontTryRemove=$false;

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting WinService script."
Write-Log -Message "Starting WinService script." -Path $sLogFile -Level Info; 

Try
{

  if($serviceloc -eq "remote") 
  {
    Write-Host "Creating PS Session."
    Write-Log -Message "Creating PS Session." -Path $sLogFile -Level Info; 

    #Set session name variable for removing the session later 
    $SessionName = "$($servicecommand)_$($service)_$($server)"

    # Create a PowerShell session on the remote computer 
    $Session = New-PSsession -Computername $server -Name $SessionName 
  }
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
	Write-Host "New-PSSession failed for: Computername=$server Name=$SessionName" -foregroundcolor "Red";
	Write-Log -Message "New-PSSession failed for: Computername=$server Name=$SessionName : Eror" -Path $sLogFile -Level Error;
	$DontTryRemove=$true;

	exit 1;
}

Try
{
  #Using switch staement in place of multiple if statements 
  Switch ($servicecommand) { # Stop/Start/Restart/Suspend/Resume the Service
    stop    { $Command = { param ($Service); Stop-Service $service -verbose -ErrorVariable StopError; } }
    start   { $Command = { param ($Service); Start-Service $service -verbose -ErrorVariable StartError; } }
    restart { $Command = { param ($Service); Restart-Service $service -verbose } }
    suspend { $Command = { param ($Service); Suspend-Service $service -verbose } }
    resume  { $Command = { param ($Service); Resume-Service $service -verbose  } } }
	
    if($serviceloc -eq "remote") 
	{
      Invoke-Command -Verbose -Session $Session -ScriptBlock $Command -ArgumentList $Service
    }
    elseif($serviceloc -eq "local") 
	{
      Invoke-Command -Verbose -Script $Command -ArgumentList $Service
    }
}
Catch
{
  # If we had a failure trying to stop the service - "hard kill" it
  if($StopError)
  {
    Write-Host Stop failed - trying to hard Kill Windows Service:$Service -foregroundcolor "Red" 
    Write-Log -Message "Stop failed - trying to hard Kill Windows Service:$Service" -Path $sLogFile -Level Error;

    $ServicePID = (Get-Wmiobject win32_Service | Where { $_.Name -eq $Service }).ProcessID
    taskkill /f /t /pid $ServicePID
	
	exit 1;
  }
  if($StartError)
  {
	Write-Host Start failed - trying to start Windows Service:$Service -foregroundcolor "Red" 
    Write-Log -Message "Start failed - trying to start Windows Service:$Service" -Path $sLogFile -Level Error;

	exit 1;
  }
}
Finally{
  if($serviceloc -eq "remote" -And $DontTryRemove -eq $false)
  {
    # Remove the PowerShell session on the remote computer
    Write-Log -Message "Removing PSsession $SessionName" -Path $sLogFile -Level Info;
    Remove-PSSession -Name $SessionName
  }
}


