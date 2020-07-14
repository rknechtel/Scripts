
@echo off
setlocal EnableDelayedExpansion
REM *******************************************************************************
REM Script: MavenArtifactUpload.bat
REM Author: Richard Knechtel
REM Date: 02/19/2020
REM Description: This script will upload dependencies to an Artifact Repository.
REM
REM *******************************************************************************

echo.
echo Running as user: %USERNAME%
echo.

REM Get parameters
set POMFILE=%1
set POMFILEEXT=%~x1
set JARFILE=%2
set REPOSITORYID=%3
set REPOSITORYURL=%4

echo.
echo Parameters Passed: 
echo Pom File: %POMFILE%
echo Jar File: %JARFILE%
echo Repository ID: %REPOSITORYID%
echo Repository URL: %REPOSITORYURL%
echo.

REM Check if we got ALL parameters
if "!POMFILE!"=="" goto usage
if "!JARFILE!"=="" goto usage
if "!REPOSITORYID!"=="" goto usage
if "!REPOSITORYURL!"=="" goto usage
if "!POMFILE!"=="" if "!JARFILE!"=="" if "!REPOSITORYID!"=="" if "!REPOSITORYURL!"=="" (
   goto usage
)

@echo Pom File Extension is: %POMFILEEXT%
if "!POMFILEEXT!"==".xml" goto continue

REM Pom file paramteter not a pom.xml file - lets get out of here!
@echo NOTE: The first paramter must be a pom.xml file. One was not found, exiting.
goto getoutofhere


:continue
REM Uploading artifact to remote Artifact Repository
@echo Uploading artifact to remote Artifact Repository
mvn deploy:deploy-file -DpomFile=%POMFILE% -Dfile=%JARFILE% -DrepositoryId=%REPOSITORYID% -Durl=%REPOSITORYURL%

REM Lets get out of here!
goto getoutofhere

:usage
set ERRORNUMBER=1
echo [USAGE]: MavenArtifactUpload.bat arg1 arg2 arg 3 arg 4
echo arg1 = Pom File Name (full path) (Example: D:\dependancyuploads\pom.xml) 
echo arg2 = Jar File name full path) (Example: D:\dependancyuploads\My-Common-Dao.jar) 
echo arg3 = Repository ID (Example: MyRepoID) (Note: this is the value in the <repository>  <id> </id> tag.)
echo arg4 = Repository URL (Example: https://MyRemoteRepo.com/MyRepoID/MyRepo/maven/ 

@echo Example Usage:
@echo D:\Scripts\Maven\MavenArtifactUpload.bat D:\work\gitconvert\my-utils-2.0.1.pom.xml D:\work\gitconvert\my-utils-2.0.1.jar MyFeed "https://MyRemoteRepo.com/MyRepoID/MyRepo/maven/"

goto getoutofhere

REM ****************************************************************************
REM Exit Script
REM ****************************************************************************
:getoutofhere
Exit /B %ERRORNUMBER%
