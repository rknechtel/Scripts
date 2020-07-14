<#
.SYNOPSIS
  <Overview of script>
Sends SMTP email via the O365 Email Server

.DESCRIPTION
  This script will send emails via an O365 Email Server
  NOTE: The account used in the Credentials must be a valid O365 account.
        The Credential Account should be: me@mycompany.onmicrosoft.com
        Using the "No Reply" account, the "From:" should be: me@mycompany.com
        The Credentials parameter must be a Base64 encoded username and password.
        Base64 Encode:
        DOMAIN\username:password


.INPUTS Credentials
.INPUTS To
.INPUTS From
.INPUTS CC (Optional)
.INPUTS BCC (Optional)
.INPUTS Attachment (Optional)
.INPUTS Subject
.INPUTS Body
.INPUTS BodyAsHTML

.OUTPUTS
Sent Email

.NOTES
  Script Name:    O365EmailSender.ps1
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  11/22/2016
  Purpose/Change: Initial script development

.EXAMPLE
 From Command line:
  - Optional Prameters must be sent as empty strings ""
No Attachment:
.\O365EmailSender.ps1 -Credentials "VABoAGkAcwAgAGkAcwAgAGEAIABzAGUAYwByAGUAdAAgAGEAbgBkACAAcwBoAG8AdQBsAGQAIABiAGUAIABoAGkAZABlAG4A" -To "administrator@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "" -Subject "Test email" -Body "This is a test" -BodyAsHTML "false"
 Single Attachment:
 .\O365EmailSender.ps1 -Credentials "VABoAGkAcwAgAGkAcwAgAGEAIABzAGUAYwByAGUAdAAgAGEAbgBkACAAcwBoAG8AdQBsAGQAIABiAGUAIABoAGkAZABlAG4A" -To "administrator@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "C:\mydirectory\myfile.csv" -Subject "Test email" -Body "This is a test" -BodyAsHTML "false"

 Multiple receipents:
 .\O365EmailSender.ps1 -Credentials "VABoAGkAcwAgAGkAcwAgAGEAIABzAGUAYwByAGUAdAAgAGEAbgBkACAAcwBoAG8AdQBsAGQAIABiAGUAIABoAGkAZABlAG4A" -To "administrator@somedomain.com,administrator2@somedomain.com,administrator3@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "C:\mydirectory\myfile.csv" -Subject "Test email" -Body "This is a test" -BodyAsHTML "false"

 Multple Attachments:
  .\O365EmailSender.ps1 -Credentials "VABoAGkAcwAgAGkAcwAgAGEAIABzAGUAYwByAGUAdAAgAGEAbgBkACAAcwBoAG8AdQBsAGQAIABiAGUAIABoAGkAZABlAG4A" -To "administrator@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "C:\mydirectory\*.csv" -Subject "Test email" -Body "This is a test" -BodyAsHTML "false"
OR
  .\O365EmailSender.ps1 -Credentials "VABoAGkAcwAgAGkAcwAgAGEAIABzAGUAYwByAGUAdAAgAGEAbgBkACAAcwBoAG8AdQBsAGQAIABiAGUAIABoAGkAZABlAG4A" -To "administrator@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "C:\mydirectory\file1.csv,C:\mydirectory\file2.csv" -Subject "Test email" -Body "This is a test" -BodyAsHTML "false"


 From within DOS Batch File: 
 - Optional Prameters must be sent as empty strings ""
 PowerShell -ExecutionPolicy Bypass -File D:\Scripts\O365EmailSender.ps1 -Credentials "VABoAGkAcwAgAGkAcwAgAGEAIABzAGUAYwByAGUAdAAgAGEAbgBkACAAcwBoAG8AdQBsAGQAIABiAGUAIABoAGkAZABlAG4A" -To "administrator@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "C:\mydirectory\myfile.csv" -Subject "Test email" -Body "This is a test" -BodyAsHTML "false"

 From another PowerShell Script (.ps1): 
 - Optional Prameters must be sent as empty strings ""
 invoke-expression -Command D:\Scripts\O365EmailSender.ps1 "VABoAGkAcwAgAGkAcwAgAGEAIABzAGUAYwByAGUAdAAgAGEAbgBkACAAcwBoAG8AdQBsAGQAIABiAGUAIABoAGkAZABlAG4A" "administrator@somedomain.com" "me@somedomain.com" "them@somedomain.com" "them2@somedomain.com" "C:\mydirectory\myfile.csv" "Test email" "This is a test" "false"

#>


#---------------------------------------------------------[Script Parameters]------------------------------------------------------
param(
[Parameter(Mandatory=$true)]
[string]$Credentials,
# For mulitple To's send as comma delimited string
[Parameter(Mandatory=$true)]
#[string[]]$to,
[string]$to,
[Parameter(Mandatory=$true)]
[string]$from,
# For mulitple CC's send as comma delimited string
[Parameter(Mandatory=$false)]
[string[]]$cc,
# For mulitple BCC's send as comma delimited string
[Parameter(Mandatory=$false)]
[string[]]$bcc,
[Parameter(Mandatory=$false)]
[string[]]$attachment,
[Parameter(Mandatory=$true)]
[string]$subject,
[Parameter(Mandatory=$true)]
[string]$body,
[Parameter(Mandatory=$false)]
[string]$bodyashtml
# Note: If enabling any of the below - must add a comma "," after $bodyashtml (above) and update "Example"
#[Parameter(Mandatory=$false)]
#[string]$deliverynotificationoption,
#[Parameter(Mandatory=$false)]
#[string]$encoding,
#[Parameter(Mandatory=$false)]
#[string]$priority,
#[Parameter(Mandatory=$false)]
#[string]$usessl
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
New-PSDrive -Name X -PSProvider FileSystem -Root C:\PowerShell\Powershell
Set-Location X:
Import-module X:\Functions\Write-Log.psm1 -Force

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Script Version
$sScriptVersion = '1.0'

#Log File Info
$sLogPath = "C:\Temp" # Change to where you want to Log to
$sLogName = "O365EmailSender.log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

Write-Host "Log File is $sLogFile;
Write-Log -Message "Log File is -Path $sLogFile; 

# Setup O365 Server and Port #
$SMTPServer = "smtp.office365.com";
$SMTPPort = "587" # TLS;
#$SMTPPort = "25" # SMTP;


# Create the Blank Mail Message Object to Build up
$msg = New-Object Net.Mail.MailMessage;


#-----------------------------------------------------------[Functions]------------------------------------------------------------



#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host "Starting O365EmailSender script.";
Write-Log -Message "Starting O365EmailSender script." -Path $sLogFile -Level Info; 


# From: O365 Account sending FROM must match an AD Account this script is run as.
$From = $from
$msg.From = New-Object Net.Mail.MailAddress($From);


# Check if we got multiple receipients (To:)
$TempTo = [System.Collections.ArrayList]@()
if($to.Contains(","))
{
  [string[]]$To = $to.Split(',');
  foreach($item in $To)
  {
    $msg.To.Add((New-Object Net.Mail.MailAddress($item)));
  }

}
else
{
  $To = $to;
  $msg.To.Add((New-Object Net.Mail.MailAddress($To)));
}


# Check if we got multiple Carboy Copies (Cc:)
if ($cc.Contains(","))
{
  [string[]]$Cc = $cc.Split(',');
  foreach($item in $Cc)
  {
    $msg.To.Add((New-Object Net.Mail.MailAddress($item)));
  }
}
else
{
  $Cc = $cc;
  $msg.To.Add((New-Object Net.Mail.MailAddress($Cc)));
}


# Check if we got multiple Blind Carboy Copies (Bcc:)
if ($bcc.Contains(","))
{
  [string[]]$Bcc=$bcc.Split(',');
  foreach($item in $Bcc)
  {
    $msg.To.Add((New-Object Net.Mail.MailAddress($item)));
  }
}
else
{
  $Bcc=$bcc;
  $msg.To.Add((New-Object Net.Mail.MailAddress($Bcc)));
}


# Add Attachment(s)
If ($attachment -like '*,*')
{
  # Comma seperated list of attachemnts: WORKS!
  $Attachments = $attachment -split ",";
}
ElseIf($attachment -match '\*.')
{
  # Wildcard list of attachments (Example: *.xlsx): WORKS!
  Write-Log -Message "Processing Multiple Attachments (Wildcarded) - $attachment" -Path $sLogFile -Level Info;
  $Attachments = @(get-childitem "$attachment")
  Write-Log -Message "Checking Wildcarded Attachments - $Attachments" -Path $sLogFile -Level Info;
}
Else
{
  $Attachment = $attachment;
}
Write-Log -Message "Checking our Attachments: $Attachments" -Path $sLogFile -Level Info; 


# Setup Subject and Email Body and if Body is HTML or not
$Subject = $subject
$msg.Subject = $Subject;

$Body = $body
$msg.Body = $Body;


Write-Log -Message "Checking bodyashtml: $bodyashtml" -Path $sLogFile -Level Info;
$IsBodyHTML=$bodyashtml;
If($IsBodyHTML-ieq "true")
{
  $msg.IsBodyHTML=$True
}

# Setup getting credentials:
$Creds=$Credentials;
$DecodedCredentials = X:\Completed\Base64EncodeDecode.ps1 decode $Creds

$seperatorIndexSlash = $DecodedCredentials.IndexOf('\');
$seperatorIndexColon = $DecodedCredentials.IndexOf(':');

$domain = $DecodedCredentials.Substring(0, $seperatorIndexSlash);
Write-Host("domain=" + $domain);

if($domain -eq "")
{
  $domain = "MY_DOMAIN";
}

$Start=$seperatorIndexSlash + 1;
$End=$seperatorIndexColon - $Start;
$username = $DecodedCredentials.Substring($Start,$End);
$securepw = $DecodedCredentials.Substring($seperatorIndexColon + 1);


#Write-Host("Credentials: username=" + $username + " securepw=" + "XXXXXXXXX" + " domain=" + $domain);
#Write-Log -Message "Credentials: username=$username  securepw=XXXXXXXXX domain=$domain" -Path $sLogFile -Level Info;


# Check if we got passed multiple attachments if so attach them all to message:
If($Attachments -ne $null -And $Attachments.length -gt 0)
{
  Foreach($file in $Attachments)
  {
    Write-Host “Attaching File : $file";
    Write-Log -Message "Attaching File : $file" -Path $sLogFile -Level Info;
    $att = New-Object Net.Mail.Attachment($file);
    $msg.Attachments.Add($att);
  } 
}
# Check if we got sent ONE attachment - if so attach it to message:
ElseIf($Attachment -ne $null -And $Attachment.Length -gt 0) 
{
  $msg.Attachments.Add($Attachment);
}

# Build up SMTP Client:
$smtp = New-Object Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
$smtp.UseDefaultCredentials = $false;

# Need this if when sending via O365:
$smtp.DeliveryMethod = [System.Net.Mail.SmtpDeliveryMethod]'Network';

# For Sending OVer TLS need to use SSL
$smtp.EnableSsl = $true;

# Need this if using TLS
$smtp.TargetName = "STARTTLS/smtp.office365.com";

# Populate Credentials on SMTP Client
$smtp.Credentials = New-Object System.Net.NetworkCredential( $username , $securepw , $domain );


try 
{
  # Try to send the Email:
  Write-Log -Message "Sending Email to O365" -Path $sLogFile -Level Info;
  $smtp.Send($msg);
  Write-Log -Message "Email sent to O365 successfully" -Path $sLogFile -Level Info;
}  
catch
{
  # catch any errors and report them
  $ErrorMessage = $_.Exception.Message;
  $FailedItem = $_.Exception.ItemName;
  Write-Log -Message "Exception caught in O365EmailSender: $ErrorMessage" -Path $sLogFile -Level Error;
}
finally
{
  Write-Host "Removing mapped Drive X";
  Write-Log -Message "Removing mapped Drive X" -Path $sLogFile -Level Info;
  Remove-PSDrive-name X
}
