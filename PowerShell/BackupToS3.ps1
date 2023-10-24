
<#
.SYNOPSIS
  This script will backup files to S3
  
.DESCRIPTION
  <Brief description of script>
  
.PARAMETER <Parameter_Name>
    Source Drive
    Source Folder
    S3 Bucket
    S3 Folder
	
.INPUTS
  <Inputs if any, otherwise state None>
  
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
  
.NOTES
  Script Name: BackupToS3.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  10/20/2023
  Purpose/Change: Initial script development
  
  Requires: AWS Tools for PowerShell 
  PS> Install-Module -Name AWS.Tools.Common
  Ref:
  https://aws.amazon.com/powershell/


.EXAMPLE
  BackupToS3.ps1 "C:\" "MyAppConfig" "MyAppConfig" "DEV"
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
param(
[Parameter(Mandatory=$true)]
[string]$sourceDrive,
[Parameter(Mandatory=$true)]
[string]$sourceFolder,
[Parameter(Mandatory=$true)]
[string]$s3Bucket,
[Parameter(Mandatory=$true)]
[string]$s3Folder
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

#New-PSDrive -Name E -PSProvider FileSystem -Root C:\Scripts\PowerShell
Set-Location C:
# Note: This module is loctaed in the Scripts\PowerShell\Modules directory.
Import-module C:\Scripts\PowerShell\Modules\Write-Log.psm1 -Force
Import-Module “C:\Program Files\WindowsPowerShell\Modules\AWS.Tools.Common\4.1.434\AWS.Tools.Common.psd1”

$global:ReturnCodeMsg = "Completed Successfully"

$RegionEndpoint = "us-east-1"

# Amazon S3 Credentials
#Credentials initialized
$credsCSV = Get-ChildItem "C:\aws\Automation\credentials.csv"
$credsContent = Import-Csv $credsCSV.FullName
$accessKeyID = $credsContent.'Access key ID'
$secretAccessKey = $credsContent.'Secret access key'

# Amazon S3 Configuration
$config=New-Object Amazon.S3.AmazonS3Config
$config.RegionEndpoint= [Amazon.RegionEndpoint]:: "us-east-1"
$config.ServiceURL= "https://s3.us-east-1.amazonaws.com"

Initialize-AWSDefaults -Region $RegionEndpoint -AccessKey $accessKeyID -SecretKey $secretAccessKey

$sourcePath = $sourceDrive + $sourceFolder



#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#Log File Info
$sLogPath = "C:\Logs"
$sLogName = "BackupToS3.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

Write-Host "Log File is $sLogFile;
Write-Log -Message "Log File is -Path $sLogFile; 


#-----------------------------------------------------------[Functions]------------------------------------------------------------

<
# Example function template
Function RecurseFolders([string]$path){
  
  Begin{
    Write-Log -Message "BackupToS3: RecurseFolders() Backup up Files to S3" -Path $sLogFile -Level Info;
  }
  
  Process{
    Try{

      Write-Log -Message "BackupToS3: RecurseFolders() Passed Source Path: $path" -Path $sLogFile -Level Info;

      $fc = New-Object -com Scripting.FileSystemObject
      $folder = $fc.GetFolder($path)
      foreach ($i in $folder.SubFolders) {
        $thisFolder = $i.Path
        # Transform the local directory path to notation compatible with S3 Buckets and Folders
        
        # 1. Trim off the drive letter and colon from the start of the Path
        $s3Path = $thisFolder.ToString()
        $s3Path = $s3Path.SubString(2)
        
        # 2. Replace back-slashes with forward-slashes
        # Escape the back-slash special character with a back-slash so that it reads it literally, like so: "\\"
        $s3Path = $s3Path -replace "\\", "/"
        $s3Path = "/" + $s3Folder + $s3Path

        # Upload directory to S3
        Write-S3Object -BucketName $s3Bucket -ClientConfig $config -Folder $thisFolder -KeyPrefix $s3Path
      }

      # If subfolders exist in the current folder, then iterate through them too
      foreach ($i in $folder.subfolders) {
        RecurseFolders($i.path)
      }

    }
    
    Catch{
      Write-Log -Message "BackupToS3: RecurseFolders()Failed backup up filees to S3." -Path $sLogFile -Level Error;
      Break
    }
  }
  
  End{
    If($?){
      Write-Log -Message "BackupToS3: RecurseFolders() Completed Successfully.." -Path $sLogFile -Level Info;
      Write-Log -Message " " -Path $sLogFile -Level Info;
    }
  }
}
>


#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting BackupToS3 script.";
Write-Log -Message "********************************" -Path $sLogFile -Level Info;
Write-Log -Message "Starting BackupToS3 script." -Path $sLogFile -Level Info; 

try 
{
  # Try to send the Email:
  Write-Log -Message "Starting BackupToS3" -Path $sLogFile -Level Info;
  
  # Upload root directory files to S3
  $s3Path = "/" + $s3Folder + "/" + $sourceFolder
  Write-S3Object -BucketName $s3Bucket -Folder $sourcePath -KeyPrefix $s3Path

  # Upload subdirectories to S3
  Write-Log -Message "BackupToS3: Source Path: $sourcePath" -Path $sLogFile -Level Info;
  RecurseFolders($sourcePath)
  
  Write-Log -Message "FInished Running BackupToS3" -Path $sLogFile -Level Info;
}  
catch
{
  # catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Log -Message "Exception caught in BackupToS3: $ErrorMessage" -Path $sLogFile -Level Error;
}
finally
{

  Write-Host "Finished running BackupToS3 script.";
  Write-Log -Message "Finished running BackupToS3 script." -Path $sLogFile -Level Info; 
  Write-Log -Message "********************************" -Path $sLogFile -Level Info;

  $global:ReturnCodeMsg="There was an Error in BackupToS3."
}

return $ReturnCodeMsg
