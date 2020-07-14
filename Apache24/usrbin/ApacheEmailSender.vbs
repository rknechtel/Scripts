' ApacheEmailSender.vbs
' --------------------------------------------------------------
' Change Log
' --------------------------------------------------------------
' Richard Knechtel 04/03/2018 - Created
' --------------------------------------------------------------

' Check for missing arguments.
Set args = WScript.Arguments
IF args.count > 0 THEN
  Set args = WScript.Arguments
  arg1 = args.Item(0)  'Environment
  arg2 = args.Item(1) 'IP Address
  message = "Alert from " & arg1 & " External Apache - mod_evasive HTTP Blacklisted IP " & arg2 & ""
End If
 
Set objEmail = CreateObject("CDO.Message")
objEmail.From = "NoReply-ApacheAlerts@mydomain.com"
'objEmail.To = "WildflyAdmins@mydomain.com,"
objEmail.To = "rknechtel@mydomain.com,"
arg1 = args.Item(0) 
objEmail.Subject = "Alert From " & arg1 & " External Apache - Blocked IP by mod_evasive"
' objEmail.AddAttachment "D:/temp/somefile.txt"

objEmail.Textbody = message

objEmail.Configuration.Fields.Item _
    ("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2 
objEmail.Configuration.Fields.Item _
    ("http://schemas.microsoft.com/cdo/configuration/smtpserver") = _
        "smtp.ad.mydomain.com" 
objEmail.Configuration.Fields.Item _
    ("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = 25 
objEmail.Configuration.Fields.Update
objEmail.Send