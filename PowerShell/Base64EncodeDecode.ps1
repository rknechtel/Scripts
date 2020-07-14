

<#
.SYNOPSIS
  Does Base64 Encoding/Decoding
  
.DESCRIPTION
  This script will do Base64 Encoding and Decoding
  

	
.INPUTS Function
.INPUTS TextToEncodeDecode

  
.OUTPUTS
  Base64 Encoded or Decoded String
  
.NOTES
  Script Name: Base64EncodeDecode.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  01/19/2017
  Purpose/Change: Initial script development
  
.EXAMPLE
  Base64EncodeDecode.ps1 encode mytexttoencode
  Output: bQB5AHQAZQB4AHQAdABvAGUAbgBjAG8AZABlAA==

  Base64EncodeDecode.ps1 decode bQB5AHQAZQB4AHQAdABvAGUAbgBjAG8AZABlAA==
  Output: mytexttoencode
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
param(
# Operation: encode or decode
[Parameter(Mandatory=$true)]
[string]$Operation,
# Text string to Encode or Decode
[Parameter(Mandatory=$true)]
[string]$TextToEncodeDecode

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
#New-PSDrive -Name Z -PSProvider FileSystem -Root C:\Powershell\Functions
#Set-Location Z:
#Import-module Z:\Write-Log.psm1 -Force

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#Log File Info
#$sLogPath = "C:\Temp" # Change to where you want to Log to
#$sLogName = "Base64EncodeDecode.log"
#$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#Write-Host "Log File is $sLogFile;
#Write-Log -Message "Log File is -Path $sLogFile; 

#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

$Op=$Operation
$Text=$TextToEncodeDecode
$ReturnValue=""

try 
{
  # Try to send the Email:
  Write-Host "Running $Op";
  #Write-Log -Message "Running $Op" -Path $sLogFile -Level Info;

  If($Op-ieq "encode")
  {
    $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Text);
    $EncodedText =[Convert]::ToBase64String($Bytes);
    $ReturnValue=$EncodedText;
  }
  ElseIf($Op-ieq "decode")
  {
    $DecodedText = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Text));
    $ReturnValue=$DecodedText;
  }
  Else
  {
    # Error - not a valid operation!
    Write-Host "$Op is not a valid operation!";
    #Write-Log -Message "$Op is not a valid operation!" -Path $sLogFile -Level Error;
    exit;
  }

  Write-Host "Finished doing $Op";
  #Write-Log -Message "Fnished doing $Op" -Path $sLogFile -Level Info;

  return $ReturnValue;
}  
catch
{
  # catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Host "Error in Base64EncodeDecode: $ErrorMessage";
  #Write-Log -Message "Error in Base64EncodeDecode: $ErrorMessage" -Path $sLogFile -Level Error;
}
finally
{
  #Write-Host "Removing mapped Drive Z";
  #Write-Log -Message "Removing mapped Drive Z" -Path $sLogFile -Level Info;
  #Remove-PSDrive-name Z
}
