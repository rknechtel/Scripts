
<#
.SYNOPSIS
  <Overview of script>
Sends SMTP email via SMTP Email Server

.DESCRIPTION
  This script will send emails via an SMTP Email Server

.INPUTS To
.INPUTS From
.INPUTS CC (Optional)
.INPUTS BCC (Optional)
.INPUTS Attachment (Optional)
.INPUTS Subject
.INPUTS Body

.OUTPUTS
Sent Email

.NOTES
  Version:        1.0
  Author:         Richard Knechtel
  Creation Date:  11/01/2016
  Purpose/Change: Initial script development

.EXAMPLE
 From Command line:
 - Optional Prameters must be sent as empty strings ""
 Single Attachment:
 .\EmailSender.ps1 -To "administrator@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "C:\mydirectory\myfile.csv" -Subject "Test email" -Body "This is a test"

 Multiple receipents:
 .\EmailSender.ps1 -To "administrator@somedomain.com,administrator2@somedomain.com,administrator3@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "C:\mydirectory\myfile.csv" -Subject "Test email" -Body "This is a test"

 Multple Attachments:
  .\EmailSender.ps1 -To "administrator@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "C:\mydirectory\*.csv" -Subject "Test email" -Body "This is a test"
OR
  .\EmailSender.ps1 -To "administrator@somedomain.com" -From "me@somedomain.com" -CC "them@somedomain.com" -BCC "them2@somedomain.com" -Attachment "C:\mydirectory\file1.csv,C:\mydirectory\file2.csv" -Subject "Test email" -Body "This is a test"  


 From within DOS Batch File: 
 - Optional Prameters must be sent as empty strings ""
 PowerShell -ExecutionPolicy Bypass -File D:\Scripts\EmailSender.ps1 "administrator@somedomain.com" "me@somedomain.com" "them@somedomain.com" "them2@somedomain.com" "C:\mydirectory\myfile.csv" "Test email" "This is a test"

 From another PowerShell Script (.ps1): 
 - Optional Prameters must be sent as empty strings ""
 invoke-expression -Command D:\Scripts\EmailSender.ps1 "administrator@somedomain.com" "me@somedomain.com" "them@somedomain.com" "them2@somedomain.com" "C:\mydirectory\myfile.csv" "Test email" "This is a test"

#>

param(
[Parameter(Mandatory=$true)]
[string[]]$to,
[Parameter(Mandatory=$true)]
[string]$from,
[Parameter(Mandatory=$false)]
[string[]]$cc,
[Parameter(Mandatory=$false)]
[string[]]$bcc,
[Parameter(Mandatory=$false)]
[string[]]$attachment,
[Parameter(Mandatory=$true)]
[string]$subject,
[Parameter(Mandatory=$true)]
[string]$body
# Note: If enabling any of the below - must add a comma "," after $body (above) and update "Example"
#[Parameter(Mandatory=$false)]
#[string]$bodyashtml,
#[Parameter(Mandatory=$false)]
#[string]$deliverynotificationoption,
#[Parameter(Mandatory=$false)]
#[string]$encoding,
#[Parameter(Mandatory=$false)]
#[string]$priority,
#[Parameter(Mandatory=$false)]
#[string]$usessl
)

$From = $from
# Check if we got multiple receipients (To:)
if(!$to -And $to.Contains(","))
{
  $To = $to.Split(',')
}
else
{
  $To = $to
}

# Check if we got multiple Carboy Copies (Cc:)
if (-not ([string]::IsNullOrEmpty($cc)))
{
    if($cc.Contains(","))
    {
      $Cc = $cc.Split(',')
    }
    else
    {
      $Cc = $cc
    }
}

# Check if we got multiple Blind Carboy Copies (Bcc:)
if (-not ([string]::IsNullOrEmpty($bcc)))
{
    if ($bcc.Contains(","))
    {
      $Bcc=$bcc.Split(',')
    }
    else
    {
      $Bcc=$bcc
    }
}

# Add Attachment(s)
if (-not ([string]::IsNullOrEmpty($attachment)))
{
    if($attachment.Contains(","))
    {
      $Attachments = $attachment.Split(',')
    }
    ElseIf($attachment.Contains("*."))
    {
      $Attachments = @(get-childitem $attachment)
    }
    else
    {
      $Attachment = $attachment
    }
}

$Subject = $subject
$Body = $body

<#
 BodyAsHtml - Valid options are:
 $true
 $false
#>
#$BodyAsHtml = $bodyashtml

<#
  DeliveryNotificationOption - Valid Options are:
    None. = No notification.
    OnSuccess. = Notify if the delivery is successful.
    OnFailure. = Notify if the delivery is unsuccessful.
    Delay. = Notify if the delivery is delayed.
    Never. = Never notify.
#>
#$DeliveryNotificationOption=$deliverynotificationoption

<#
  Encoding - Valid Options are:
    ASCII
    UTF8
    UTF7
    UTF32
    Unicode
    BigEndianUnicode
    Default
    OEM
   Note: ASCII is the default.
#>
#$Encoding=$encoding

<#
  Priority - Valid Options are:
    Normal
    High
    Low
    Note: Normal is the default.
#>
#$Priority=$priority

<#
 UseSsl - Valid Options are:
  $true
  $false
#>
#$UseSsl=$usessl
# $SMTPClient.EnableSsl = $UseSsl

$SMTPServer = "smtp.mydomain.com"
$SMTPPort = "25"



<#
# Create an instance Microsoft Outlook
$Outlook = New-Object -ComObject Outlook.Application
$Mail = $Outlook.CreateItem(0)
#>

$SMTPClient = New-Object System.Net.Mail.smtpClient
$SMTPClient.Host=$SMTPServer
$SMTPClient.Port=$SMTPPort

$MailMessage = New-Object System.Net.Mail.MailMessage
$MailMessage.To.Add($To);
$MailMessage.From = $From;
$MailMessage.Subject = $Subject;
$MailMessage.Body = $Body;

If ($Cc -ne $null -And $Cc.Length -gt 0) 
{
  $MailMessage.CC=$Cc
}
If ($Bcc -ne $null -And $Bcc.Length -gt 0) 
{
  $MailMessage.Bcc=$Bcc
}

# Check if we got passed multiple attachments:
If($Attachments -ne $null -And $Attachments.Length -gt 0)
{
  Foreach($file in $Attachments)
  {
    Write-Host “Attaching File : ” $file
    $Attachment = New-Object System.Net.Mail.Attachment –ArgumentList $file
    $MailMessage.Attachments.Add($Attachment)
  } 
}
# Check if we got sent ONE attachment:
ElseIf($Attachment -ne $null -And $Attachment.Length -gt 0) 
{
  $SingleAttachment = New-Object System.Net.Mail.Attachment –ArgumentList $Attachment
  $MailMessage.Attachments.Add($SingleAttachment)
}

<#
Change Script to use these if needed:

$Username = $username
$Password = $password
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password); 
$SMTPClient.EnableSsl=$UseSsl  # $true/$false
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($Username, $Password); 

$MailMessage.BodyEncoding=
$MailMessage.DeliveryNotificationOptions=
$MailMessage.IsBodyHtml=           # $true/$false

#>


# Send the Email!
$SMTPClient.Send($MailMessage)
# Clean Up:
Remove-Variable -Name SMTPClient
#Remove-Variable -Name Password
