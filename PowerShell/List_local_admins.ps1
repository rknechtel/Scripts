
# ****************************************************************************
#
# Script Name: List_local_admins.ps1
# Description: Will get a list of anyone in the Servers Local Admin Group
#
# ****************************************************************************

# In servers.txt - put a list of server names to query (one server per line)
$servers= get-content 'D:\Work\servers.txt'
$output = 'D:\Work\local_admin_output.csv'
$results = @()

foreach($server in $servers)
{
  $admins = @()
  $group =[ADSI]"WinNT://$server/Administrators"
  $members = @($group.psbase.Invoke("Members"))
  $members | foreach {
    $obj = new-object psobject -Property @{
      Server = $Server
      Admin = $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }

    $admins += $obj
  }

  $results += $admins
}

$results| Export-csv $Output -NoTypeInformation
