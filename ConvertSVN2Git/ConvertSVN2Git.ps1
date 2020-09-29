
<#
	.SYNOPSIS
  This script will convert a Project in SVN to GIT
  
.DESCRIPTION
  This script will convert a Project in SVN to GIT
  
.PARAMETER <Parameter_Name>
    SvnPath - SVN Project URL or Local Path
    TargetPath - Path to target GIT project directory (local)
    AuthorsFile - path and name of authors.txt file that holds list of Name/ Email's of committers to SVN project

.INPUTS
  Pulls SVN project in for Conversion.
  
.OUTPUTS
  SVN Code converted to a GIT project, located in $TargetPath
  
.NOTES
  Script Name: ConvertSVN2Git.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  08/27/2019
  Purpose/Change: Initial script development
  
.EXAMPLE
  .\ConvertSVN2Git.ps1 -SvnPath https://svn.mydomain.com.com/svn/MyRepo/MyProject/ -TargetPath C:\Temp\MyGitProject -AuthorsFile C:\work\gitconvert\authors.txt
 
 Note 1:
 SVN project MUST be in the format of:
 MyProject
   branches
   tags
   trunk
 
 If it isn't comment out line below with "--stdlayout" in it and uncomment the one without it.
 Future enhancement I'm working on will take a parameter of whether to use the flag or not.
 
 Note 2:
  authors.txt should be in the format of:
  FirstName LastName <emailid@mydomain.com>
  
  Example:
  John Doe <jdoe@mydomain.com>
  
  Last entry in file should be:
  VisualSVN Server = Visual SVN Server <admin@mydomain.com>
  
  Important: You need an entry for -every- User that made a commit to the project.
  
#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------

Param(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$SvnPath,
    [Parameter(Mandatory=$true, Position=2)]
    [string]$TargetPath,
    [Parameter(Mandatory=$true, Position=4)]
    [string]$AuthorsFile
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
  Import-module C:\Scripts\Modules\Write-Log.psm1 -Force
  
  $global:ReturnCodeMsg = "Completed Successfully"
  
#----------------------------------------------------------[Declarations]----------------------------------------------------------
  
  #Script Version
  $sScriptVersion = "1.0"
  
  #Log File Info
  $sLogPath = "C:\Temp" # Change to where you want to Log to
  $sLogName = "ConvertSVN2Git.log"
  $sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName
  
  Write-Host "Log File is $sLogFile;
  Write-Log -Message "Log File is -Path $sLogFile; 
  
  
#-----------------------------------------------------------[Functions]------------------------------------------------------------

# N/A
  
#-----------------------------------------------------------[Execution]------------------------------------------------------------

  Write-Host "Starting ConvertSVN2Git.ps1 script.";
  Write-Log -Message "********************************" -Path $sLogFile -Level Info;
  Write-Log -Message "Starting ConvertSVN2Git.ps1 script." -Path $sLogFile -Level Info; 
  
  try 
  {
    Write-Log -Message "Starting of processing SVN code to GIT" -Path $sLogFile -Level Info;

    Write-Log -Message "Starting git svn clone of $SvnPath" -Path $sLogFile -Level Info;
    
    # If Project doesn't have standard SVN layout (branches/tags/trunk) remove the --stdlayout flag
    git svn clone --stdlayout --no-metadata -A $AuthorsFile $SvnPath "$TargetPath-tmp"
    # use below for Projects that do NOT have a standard SVN layout (like Wildfly repo)
    # git svn clone -no-metadata -A $AuthorsFile $SvnPath "$TargetPath-tmp"; 

    # This works as well
    #git svn clone --stdlayout --no-metadata -A $AuthorsFile --follow-parent --no-minimize-url $SvnPath "$TargetPath-tmp"

    Write-Log -Message "Finished git svn clone of $SvnPath" -Path $sLogFile -Level Info;

    cd "$TargetPath-tmp"

    Write-Log -Message "Starting of branch conversions" -Path $sLogFile -Level Info;

    $remoteBranches = git branch -r

    foreach($remoteBranch in $remoteBranches)
    {
        $remoteBranch = $remoteBranch.Trim()

        if($remoteBranch.StartsWith("tags/"))
        {
          $tagName = $remoteBranch.Substring(5)

            git checkout -b "tag-$tagName" $remoteBranch
            git checkout master
            git tag $tagName "tag-$tagName"
            git branch -D "tag-$tagName"
        }
        elseif($remoteBranch -notlike "trunk")
        {
            git checkout -b $remoteBranch $remoteBranch
        }
    }

    cd ..
    git clone "$TargetPath-tmp" $TargetPath
    rm -Recurse -Force "$TargetPath-tmp"
    cd $TargetPath

    $remoteBranches = git branch -r
    foreach($remoteBranch in $remoteBranches)
    {
        $remoteBranch = $remoteBranch.Trim()

        if($remoteBranch -notcontains "HEAD" -and $remoteBranch -notcontains "master")
        {
            $branchName = $remoteBranch.Substring(7)
            git checkout -b $branchName $remoteBranch
        }
    }

    Write-Log -Message "Fniished branch conversions" -Path $sLogFile -Level Info;

    Write-Log -Message "Finishing of processing SVN code to GIT" -Path $sLogFile -Level Info;

    git checkout master
    git remote rm origin
    
    Write-Log -Message "Finished ConvertSVN2Git.ps1" -Path $sLogFile -Level Info;
  }  
  catch
  {
    # catch any errors and report them
    $ErrorMessage = $_.Exception.Message;
    $FailedItem = $_.Exception.ItemName;
    Write-Log -Message "Exception caught in ConvertSVN2Git.ps1: $ErrorMessage" -Path $sLogFile -Level Error;
    $global:ReturnCodeMsg="There was an Error in ConvertSVN2Git.ps1 script."
  }
  finally
  {
    Write-Host "Removing mapped Drive X";
    Write-Log -Message "Removing mapped Drive X" -Path $sLogFile -Level Info;
    Remove-PSDrive-name X
    
    # Retrun to the calling location
    ReturnToCallingLocation
  
    Write-Host "Finished running ConvertSVN2Git.ps1 script.";
    Write-Log -Message "Finished running ConvertSVN2Git.ps1 script." -Path $sLogFile -Level Info; 
    Write-Log -Message "********************************" -Path $sLogFile -Level Info;
  
    # Setting return code/message
    #$global:ReturnCodeMsg="ConvertSVN2Git.ps1 fnished successfully."
  }

  return $ReturnCodeMsg
  