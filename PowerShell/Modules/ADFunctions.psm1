
<#
.SYNOPSIS
  This is a PowerShell Function Module of Active Directory (AD) Functions.
  
.DESCRIPTION
  This PowerShell Function Module will contain many different Active Directory (AD) Functions
  useable in PowerShell Scripts.
  
.PARAMETER <Parameter_Name>
    See individual Funcations
	
.INPUTS
  See individual Funcations
  
.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>
  
.NOTES
  Script Name: ADFunctions.psm1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  03/16/2018
  Purpose/Change: Initial script development
  
  Requires ActiveDirectory Module to be installed:
  https://4sysops.com/wiki/how-to-install-the-powershell-active-directory-module/

  List all installed PowerShell Modules:
  Get-Module -Listavailable
  
  Get-Command -verb Get -Module "ActiveDirectory"

  Cmdlets for PowerShell Module: ActiveDirectory
  -------------------------------------------------
  Get-ADAccountAuthorizationGroup
  Get-ADAccountResultantPasswordReplicationPolicy
  Get-ADComputer
  Get-ADComputerServiceAccount
  Get-ADDefaultDomainPasswordPolicy
  Get-ADDomain
  Get-ADDomainController
  Get-ADDomainControllerPasswordReplicationPolicy
  Get-ADDomainControllerPasswordReplicationPolicy...
  Get-ADFineGrainedPasswordPolicy
  Get-ADFineGrainedPasswordPolicySubject
  Get-ADForest
  Get-ADGroup
  Get-ADGroupMember
  Get-ADObject
  Get-ADOptionalFeature
  Get-ADOrganizationalUnit
  Get-ADPrincipalGroupMembership
  Get-ADRootDSE
  Get-ADServiceAccount
  Get-ADUser
  Get-ADUserResultantPasswordPolicy
  
.EXAMPLE
  See individual Funcations
#>

# Required Import Modules & Snap-ins for Scripts:
# Import-Module ActiveDirectory
# Import-module X:\Functions\Write-Log.psm1 -Force

<#
  Function: GetADGroups
  Description: This will Get all AD Groups (Security or Distribution)
  Parameters: AD Group Type (Security or Distribution)
  Example Calls: GetADGroups Security
                 GetADGroups Distribution

#>
Function GetADGroups
{
  [CmdletBinding()] 
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("ADGroupType")] 
    [string]$ADGroupType
  )
  $sGroupsName = "AD-$ADGroupType-Groups.txt"
  $sGroupsFile = Join-Path -Path $sLogPath -ChildPath $sGroupsName
  $GroupsList = New-Object System.Collection.s.ArrayList

  Begin{
    Write-Log -Message "Getting All AD Security Groups." -Path $sLogFile -Level Info;
  }
  
  Process
  {
    Try
    {
      If ("Security","Distribution" -NotContains $ADGroupType)
      {
          Throw "$($ADGroupType) is not a valid AD Group Type! Please use Security or Distribution"
      } 

      # Retrieve All AD Groups (sorted Alphabetically)
      $temp = Get-ADGroup -Filter {GroupCategory -eq "$ADGroupType"} -Properties 'Name' | Sort-Object name

      foreach($group in $temp) 
      { 
        $GroupName = $group.Name
        $GroupsList.Add("$GroupName")
        #write-output "GroupName: $GroupName"
        write-output "$GroupName" | Out-File $sGroupsFile -Append -NoClobber
      }

    }
    
    Catch{
      Write-Log -Message "Error getting AD $ADGroupType Groups." -Path $sLogFile -Level Error;
      Break
    }
  }

  Return $GroupsList
}


<#
  Function: GetADUserInformation
  Description: Get an AD Users Information
  Parameters: AD User ID
  Example Call: GetADUserInformation <AD User ID>

#>
Function GetADUserInformation
{
  [CmdletBinding()] 
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("ADuserID")] 
    [string]$ADUserID 
  )
  
  $sADuserIDName = "ADUser-$ADUserID.txt"
  $sADuserIDFile = Join-Path -Path $sLogPath -ChildPath $sADuserIDName
  $ADUserOut = ""

  Begin
  {
    Write-Log -Message "Getting AD User $ADUserID Information." -Path $sLogFile -Level Info;
  }
  
  Process
  {
    Try
    {
      # Retrieve all AD Distribution Groups
      $ADUserOut = Get-ADUser -Identity $ADUserID -Properties *
      write-output $ADUserOut | Out-File $sADuserIDFile -Append -NoClobber

    }
    
    Catch{
      Write-Log -Message "Error getting AD User $ADUserID Information." -Path $sLogFile -Level Error;
      Break
    }
  }
  
  End{
    If($?){
      Write-Log -Message "GetADUserInformation Completed Successfully.." -Path $sLogFile -Level Info;
      Write-Log -Message " " -Path $sLogFile -Level Info;
    }
  }

  Return $ADUserOut
}




<#
  Function: GetADUserGroups
  Description: Get a list of Groups an AD User is in.
  Parameters: AD User ID
  Example Call: GetADUserGroups <AD User ID>

#>
Function GetADUserGroups
{
  [CmdletBinding()] 
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("ADuserID")] 
    [string]$ADUserID 
  )
  
  $sADuserGroupsName = "ADUserGroups-$ADUserID.txt"
  $sADuserGroupsFile = Join-Path -Path $sLogPath -ChildPath $sADuserGroupsName
  $ADUserOut = ""

  Begin
  {
    Write-Log -Message "Getting AD User $ADUserID Information." -Path $sLogFile -Level Info;
  }
  
  Process
  {
    Try
    {
      # Retrieve all AD Distribution Groups (list in Alphabetical order)
      $ADUserGroupsOut = Get-ADPrincipalGroupMembership $ADUserID | select name | Sort-Object name
      write-output $ADUserGroupsOut | Out-File $sADuserGroupsFile -Append -NoClobber

    }
    
    Catch{
      Write-Log -Message "Error getting AD User $ADUserID Information." -Path $sLogFile -Level Error;
      Break
    }
  }
  
  End{
    If($?){
      Write-Log -Message "GetADUserGroups Completed Successfully.." -Path $sLogFile -Level Info;
      Write-Log -Message " " -Path $sLogFile -Level Info;
    }
  }

  Return $ADUserGroupsOut
}




<#
  Function: GetADDomainInformation
  Description: Get an AD Domain Information
  Parameters: N/A
  Example Call: GetADDomainInformation

#>
Function GetADDomainInformation
{
  param()
  
  $sADDomainName = "ADDomainInformation.txt"
  $sADDomainFile = Join-Path -Path $sLogPath -ChildPath $sADDomainName
  $ADDomainOut = ""

  Begin
  {
    Write-Log -Message "Getting AD Domain Information." -Path $sLogFile -Level Info;
  }
  
  Process
  {
    Try
    {
      # Retrieving AD Group Members (Raw) Information
      $ADDomainOut = Get-ADDomain
      write-output $ADDomainOut | Out-File $sADDomainFile -Append -NoClobber
    }
    
    Catch{
      Write-Log -Message "Error getting AD Domain Information." -Path $sLogFile -Level Error;
      Break
    }
  }
  
  End{
    If($?){
      Write-Log -Message "GetADDomainInformation Completed Successfully.." -Path $sLogFile -Level Info;
      Write-Log -Message " " -Path $sLogFile -Level Info;
    }
  }

  Return $ADDomainOut
}




<#
  Function: GetADGroupMembersRaw
  Description: Get list of members of an AD Group
  Parameters: AD Group Name
  Example Call: GetADGroupMembersRaw <ADGroupName>

#>
Function GetADGroupMembersRaw
{
  [CmdletBinding()] 
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("ADGroupName")] 
    [string]$ADGroupName
  )
  
  $sADGroupmembersName = "ADGroupMembersOf-$ADGroupName.txt"
  $sADGroupMembersFile = Join-Path -Path $sLogPath -ChildPath $sADGroupMembersName
  $GroupMembersListOut = New-Object System.Collection.s.ArrayList

  Begin
  {
    Write-Log -Message "Getting AD Group Mmebers for: $ADGroupName." -Path $sLogFile -Level Info;
  }
  
  Process
  {
    Try
    {
      # Retrieving AD Group Members (Raw) Information
      $GroupMembersListOut = Get-ADGroupMember $ADGroupName
      write-output $GroupMembersListOut | Out-File $sADGroupMembersFile -Append -NoClobber

    }
    
    Catch{
      Write-Log -Message "Error getting AD Group Mmebers for: $ADGroupName." -Path $sLogFile -Level Error;
      Break
    }
  }
  
  End{
    If($?){
      Write-Log -Message "GetADGroupMembersRaw Completed Successfully.." -Path $sLogFile -Level Info;
      Write-Log -Message " " -Path $sLogFile -Level Info;
    }
  }

  Return $GroupMembersListOut
}




<#
  Function: GetADGroupMembersIDName
  Description: Get list of members of an AD Group
  Parameters: AD Group Name
  Example Call: GetADGroupMembersIDName <ADGroupName>

#>
Function GetADGroupMembersIDName
{
  [CmdletBinding()] 
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)] 
    [ValidateNotNullOrEmpty()] 
    [Alias("ADGroupName")] 
    [string]$ADGroupName
  )
  
  $sADGroupmembersName = "ADGroupMembersOf-$ADGroupName.txt"
  write-output $sADGroupMembersFile = Join-Path -Path $sLogPath -ChildPath $sADGroupMembersName

  Begin
  {
    Write-Log -Message "Getting AD Group Mmebers for: $ADGroupName." -Path $sLogFile -Level Info;
  }
  
  Process
  {
    Try
    {
      $GroupMembersList = New-Object System.Collection.s.ArrayList
      
      # Retrieving AD Group Members (Raw) Information
      $temp = Get-ADGroupMember $ADGroupName
	  #write-output "GroupMembers for $ADGroupName:"
      foreach($member in $temp) 
      { 
        $MmeberID = $member.Name
		
		    $ADuser = Get-ADUser -Identity $MmeberID -Properties *
		    $FullName = $ADuser.DisplayName
        
        $GroupMembersList.Add("$MmeberID - $FullName")
        
        #write-output "$MmeberID - $FullName"
        write-output "$MmeberID - $FullName" | Out-File $sADGroupMembersFile -Append -NoClobber
      }	  
    }
    
    Catch{
      Write-Log -Message "Error getting AD Group Mmebers for: $ADGroupName." -Path $sLogFile -Level Error;
      Break
    }
  }
  
  End{
    If($?){
      Write-Log -Message "GetADGroupMembersIDName Completed Successfully.." -Path $sLogFile -Level Info;
      Write-Log -Message " " -Path $sLogFile -Level Info;
    }
  }
  Return $GroupMembersList
}




# END of ADFunctions.psm1
