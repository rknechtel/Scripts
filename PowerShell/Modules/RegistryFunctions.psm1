<#
.SYNOPSIS
  This is a PowerShell Function Module of Registry Functions.
  
.DESCRIPTION
  This PowerShell Function Module will contain many different Registry Functions
  useable in PowerShell Scripts.
  
.PARAMETER <Parameter_Name>
    See individual Funcations
	
.INPUTS
  See individual Funcations
  
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Temp\<name>.log>
  
.NOTES
  Script Name: RegistryFunctions.psm1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  03/19/2018
  Purpose/Change: Initial script development
  

  
.EXAMPLE
  See individual Funcations
#>

# Required Import Modules & Snap-ins for Scripts:
# Import-module X:\Functions\Write-Log.psm1 -Force

<#
  Function: Change-SharePathIndividual
  Description: This will change the path on an individual Windows Share
  Parameters: Share Name
              Old Share path
              New Share Path

  Example Calls: 
    - With the -WhatIf parameter for testing purposes:
    Change-SharePath -OldPath D:\myShare -NewPath E:\Subfolder\myNewSharePath -WhatIf

    - With the -Verbose parameter for details during the changes:
    Change-SharePath -OldPath D:\myShare -NewPath E:\Subfolder\myNewSharePath –Verbose  
	
  Note: 
       Don’t forget to restart the Server service (aka lanmanserver) after all the changes, 
	   for the new settings to take effect:
       Restart-Service -Name lanmanserver
	
#>
function Change-SharePathIndividual
{
  [cmdletbinding(SupportsShouldProcess=$true)]
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("ShareName")] 
    [string]$ShareName,  
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("OldPath")] 
    [string]$OldPath,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("NewPath")] 
    [string]$NewPath
  )
 
   Begin
  {
    Write-Log -Message "Changing Share: $ShareName path from: $OldPath to: $NewPath." -Path $sLogFile -Level Info;
  }
  
  Process
  {
    Try
    {
      $RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Shares'
	  $ShareData = Get-ItemProperty -Path $RegPath -Name $ShareName | Select-Object -ExpandProperty $ShareName
      if ($ShareData | Where-Object { $_ -eq  "Path=$OldPath"}) 
      {
        $ShareData = $ShareData -replace [regex]::Escape("Path=$OldPath"), "Path=$NewPath"
 
        if ($PSCmdlet.ShouldProcess($ShareName, 'Change-SharePath')) 
        {
          Set-ItemProperty -Path $RegPath -Name $ShareName -Value $ShareData
        }
      }
    }
	Catch
	{
      Write-Log -Message "Error Changing Share path from: $OldPath to: $NewPath." -Path $sLogFile -Level Error;
      Break
    }
  }
}

# Required Import Modules & Snap-ins for Scripts:
# Import-Module ActiveDirectory
# Import-module X:\Functions\Write-Log.psm1 -Force

<#
  Function: Change-SharePathAllPlaces
  Description: This will change the path on a Windows Share
               on every share "old path" is.
  Parameters: Old Share path
              New Share Path

  Example Calls: 
    - With the -WhatIf parameter for testing purposes:
    Change-SharePath -OldPath D:\myShare -NewPath E:\Subfolder\myNewSharePath -WhatIf

    - With the -Verbose parameter for details during the changes:
    Change-SharePath -OldPath D:\myShare -NewPath E:\Subfolder\myNewSharePath –Verbose   
	
  Note: 
       Don’t forget to restart the Server service (aka lanmanserver) after all the changes, 
	   for the new settings to take effect:
       Restart-Service -Name lanmanserver

#>
function Change-SharePathAllPlaces
{
  [cmdletbinding(SupportsShouldProcess=$true)]
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("OldPath")] 
    [string]$OldPath,
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("NewPath")] 
    [string]$NewPath
  )
 
   Begin
  {
    Write-Log -Message "Changing Share path from: $OldPath to: $NewPath." -Path $sLogFile -Level Info;
  }
  
  Process
  {
    Try
    {
      $RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Shares'
      dir -Path $RegPath | Select-Object -ExpandProperty Property | ForEach-Object 
      {
        $ShareName = $_
        $ShareData = Get-ItemProperty -Path $RegPath -Name $ShareName |
        Select-Object -ExpandProperty $ShareName
        if ($ShareData | Where-Object { $_ -eq  "Path=$OldPath"}) 
        {
          $ShareData = $ShareData -replace [regex]::Escape("Path=$OldPath"), "Path=$NewPath"
 
          if ($PSCmdlet.ShouldProcess($ShareName, 'Change-SharePath')) 
          {
            Set-ItemProperty -Path $RegPath -Name $ShareName -Value $ShareData
          }
        }
      }
    }
	Catch
	{
      Write-Log -Message "Error Changing Share path from: $OldPath to: $NewPath." -Path $sLogFile -Level Error;
      Break
    }
  }
}

# END of RegistryFunctions.psm1
