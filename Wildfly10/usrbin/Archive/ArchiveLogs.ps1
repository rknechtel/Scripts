<# ************************************************************************
 Script: ArchiveLogs.ps1
 Author: Richard Knechtel
 Date: 11/09/2017
 Description: This script will Archive Log files
 
 Notes:
   Args format from a DOS Batch file:
   PowerShell -ExecutionPolicy Bypass -File %SCRIPTPATH%\ArchiveLogs.ps1 AppSrv01 11-10-2017-AppSrv01-Logs.zip

************************************************************************ #>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
Write-Host
Write-Host "Passed Arguments:" -foregroundcolor "Red" -backgroundcolor "White"
$args
Write-Host

# Set our Variables:
$AppSrv=$args[0]
$ZipFile=$args[1]

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
$JbossHome="$env:JBOSS_HOME"
$LogDir=$JbossHome + "\" + $AppSrv + "\log"
$ArchiveLogDir=$LogDir + "\Archive"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting ArchiveLogs script."

# 2) Zip up log files.
Try
{
  Write-Host "Zipping up log files for $AppSrv in $LogDir"
  Write-Host "Archive File= "$LogDir\$ZipFile

  # Zip up log files at root of log directory:
  Get-ChildItem -File $LogDir\*  | where { $_.extension -ne ".zip"} | Compress-Archive -CompressionLevel Fastest -DestinationPath $LogDir\$ZipFile -Update
    
  # Zip up log directories at root of log directory:
  Get-ChildItem -Directory $LogDir\*  | where { $_.Name -ne "Archive"} | Compress-Archive -CompressionLevel Fastest -DestinationPath $LogDir\$ZipFile -Update
  
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
	Write-Host "Log Archiving failed." -foregroundcolor "Red";
    Write-Host "Error Messaage: "$ErrorMessage  -foregroundcolor "Red";
    Write-Host "Fail Item: "$FailedItem  -foregroundcolor "Red";

	exit 1;
}


# 3) Move zipped logs to Archive directory.
Try
{
  Write-Host "Moving zipped up log files in $LogDir for $AppSrv to the archive directory $ArchiveLogDir"  
  Move-Item $LogDir\$ZipFile $ArchiveLogDir -Force

}
Catch 
{
  $ErrorMessage = $_.Exception.Message
  $FailedItem = $_.Exception.ItemName
  Write-Host "Moving zipped up log files in $LogDir for $AppSrv to the archive directory $ArchiveLogDir failed." -foregroundcolor "Red";
  Write-Host "Error Messaage: "$ErrorMessage  -foregroundcolor "Red";
  Write-Host "Fail Item: "$FailedItem  -foregroundcolor "Red";

  exit 1;
}
  
# If the move of the zip file didn't fail remove the old files
# 4) Delete log files in logs directory.
Try
{
  Write-Host "Removing original log files for $AppSrv after archiving"
   Get-ChildItem -Path $LogDir -Exclude "Archive" | foreach ($_) {
       "CLEANING :" + $_.fullname
       Remove-Item $_.fullname -Force -Recurse
       "CLEANED... :" + $_.fullname
   }

}
Catch 
{
  $ErrorMessage = $_.Exception.Message
  $FailedItem = $_.Exception.ItemName
  Write-Host "Removing original log files for $AppSrv after archiving failed." -foregroundcolor "Red";  
  Write-Host "Error Messaage: "$ErrorMessage  -foregroundcolor "Red";
  Write-Host "Fail Item: "$FailedItem  -foregroundcolor "Red";

  exit 1;	
}


