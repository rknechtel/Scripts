
<#
.SYNOPSIS
  Ham Radio Call Sign Lookup
  
.DESCRIPTION
  This will do a Call Sign Lookup from https://callook.info
  
.PARAMETER CallSign
           <Ham Radio Call Sign>
           OutputFormat
           <Format desired for output (json, xml, text)>
	
.INPUTS
CallSign
OutputFormat
  
.OUTPUTS
  Call Sign Information in format Requested.
  Output options: XML, JSON, TEXT
  
.NOTES
  Script Name: Callookinfo.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  11/08/2017
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
  <a href="javascript:window.external.AddSearchProvider('http://callook.info/callook.xml');" title="Browser Search Plugin">Browser Search Plugin</a>  
  https://callook.info/index.php?callsign=[callsign]&display=json
  https://callook.info/index.php?callsign=[callsign]&display=xml
  https://callook.info/index.php?callsign=[callsign]&display=text

#>

#---------------------------------------------------------[Script Parameters]------------------------------------------------------
param(
[Parameter(Mandatory=$true)]
[string]$CallSign,
[Parameter(Mandatory=$true)]
[ValidateSet("json","xml","text")]
[string]$OutputFormat
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = 'SilentlyContinue'

$global:ReturnCodeMsg = "Completed Successfully"

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = "1.0"

#-----------------------------------------------------------[Execution]------------------------------------------------------------

try 
{
  # Lookup Call Sign
  $Response=Invoke-WebRequest -Uri "https://callook.info/index.php?callsign=$CallSign&display=$OutputFormat"
  Write-Host $Response
}  
catch
{
  # catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;

  # Set return code/message
  $global:ReturnCodeMsg="There was an Error in Callookinfo.ps1."
}
finally
{
  # Do any Clean up here

}

# Some Value or Variable
return $ReturnCodeMsg
