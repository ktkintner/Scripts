<#
.Synopsis
    Used to automatically reset network adapter on devices to 
    restore network connectivity. 
.DESCRIPTION
    Checks to see if computer can ping another device on the 
    network and if it is unsuccessful it will disable the 
    network adapter, wait 15 seconds and then enable the
    network adapter once again. Will email admin when the
    network adapter is reset. 
#>

#WiFi Reset Script
#Kevin Kintner
#Oct 18,2019
#
#

#sets variables 
$pingTarget = 8.8.8.8
$netAdapterName = "Wi-Fi"
$from = "Your Computer <yourcomputer@yourdomain.com>" #set to the email address you want the message to come from
$to = "You <you@yourdomain.com>" #set to the email address you want the email to go to
$subject = "Some subject" #set your email subject
$smtpServer = "smtpserver.yourdomain.com" #set this to your smtp server

#checks network connectivity and sets $netStatus to the boolean result
$netStatus = test-connection -computername $pingTarget -Quiet

#if test-connection is false then network adapter is reset and email is sent to admin via smtp server. 
If ($netStatus -ne "True"){
    Disable-NetAdapter -Name $netAdapterName -Confirm:$false
    Start-Sleep -Seconds 15
    Enable-NetAdapter -Name $netAdapterName -Confirm:$false
    Start-Sleep -Seconds 30
    Send-MailMessage -From $from -To $to -Subject $subject -SMTP $smtpServer
}
$date = Get-Date
$message = "$date - Network Status is: $netStatus"
Add-Content C:\Utilities\Scripts\WiFiStatus.log $message
