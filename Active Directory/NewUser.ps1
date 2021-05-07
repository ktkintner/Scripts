<#
Several items have been sanitized from this script, please read through it, understand what it does,
and fill in the missing items before running it in your own environment. 
#>

#Requests user input their creds so they can be stored securly while the script is executed
$userCredential = Get-Credential

$title = 'New User'
$message = 'Do you need to create a new user? (Y/N)'
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", 'Yes'
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", 'No'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
$newUser = $host.ui.PromptForChoice($title, $message, $options, 0)

If ($newUser -eq 0) {
    $title = 'Copy User'
    $message = 'Do you want to copy an existing user? (Y/N)'
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", 'Yes'
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", 'No'
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $copyUser = $host.ui.PromptForChoice($title, $message, $options, 0)
}

If ($copyUser -eq 0) {
    #Asks user if they want to create a new user
    $existingUser = Read-Host -Prompt 'Enter the username of the user you would like to copy:'
    $existingUserInstance = Get-ADUser -Identity $existingUser
    $existingUserDN = $existingUserInstance.distinguishedName
    $existingUserADSI = [ADSI]"LDAP://$existingUserDN"
    $existingUserParent = $existingUserADSI.Parent
    $existingUserOU = [ADSI]$existingUserParent
    $existingUserOUDN = $existingUserOU.distinguishedName
}

#Asks user to input new user's first and last name
$newUserFirst = Read-Host -Prompt 'Input new users first name:'
$newUserLast = Read-Host -Prompt 'Input new users last name:'
$newUserPassword = Read-Host -Prompt "Set new user password:" -AsSecureString
#Generates remaining variables based on above input
$newUserName = $newUserFirst + '.' + $newUserLast
$newUserDisplay = $newUserFirst + ' ' + $newUserLast
$newUserPrincipalName = $newUserName + "@yourdomain.com" #enter your domain here
$userHomeDir = "\\YourDFS\HomeDir\" + $newUserName #enter your directory path here
$userScanDir = "\\YourDFS\ScanDir\" + $newUserName #enter your directory path here

New-ADUser -SamAccountName $newUserName -Instance $existingUserInstance -DisplayName $newUserDisplay -GivenName $newUserFirst -Surname $newUserLast -Name $newUserDisplay -UserPrincipalName $newUserPrincipalName -Path "$existingUserOUDN" -HomeDirectory $userHomeDir -HomeDrive "X:" -AccountPassword $newUserPassword -Enable $True -ChangePasswordAtLogon $True

$title = 'Phone Extension'
$message = 'Does this user have a phone extension? (Y/N)'
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", 'Yes'
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", 'No'
$options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
$phone = $host.ui.PromptForChoice($title, $message, $options, 0)

If ($phone -eq 0) {
    $newUserExt = Read-Host -Prompt 'Input new users extension:'
    Get-ADuser -Identity $newUserName | Set-ADuser -Replace @{ipPhone=$newUserExt}
}


#Opens PSSessions to Exchange and Azure Active Directory Connect servers so commands can be run locally, set these to your respective servers 
$sessionExchange = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://exchange.yourdomain.com/PowerShell/ -Authentication Kerberos -Credential $UserCredential
$sessionAADSync = New-PSSession -ComputerName AzureADSync.yourdomain.com -Authentication Kerberos -Credential $userCredential
Import-PSSession $sessionExchange -DisableNameChecking
Import-PSSession $sessionAADSync -Module ADSync -DisableNameChecking 

#Creates mailbox for new user
Enable-RemoteMailbox "$newUserFirst $newUserLast" -RemoteRoutingAddress $newUserName@yourdomain.onmicrosoft.com #set this to match your Microsoft 365 tenant

#Starts delta sync to Office 365 
Start-ADSyncSyncCycle -PolicyType Delta

#Set properties for new ACL rule 
$identity = 'YourDomain\' + $newUserName #set this to match your domain
$fileSystemRights = "FullControl"
$inheritanceFlags = "ContainerInherit,ObjectInherit"
$propagationFlags = "None"
$type = "Allow"

#Create new ACL rule
$fileSystemAccessRuleArgumentList = $identity,$fileSystemRights,$inheritanceFlags,$propagationFlags,$type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList

#Create User Directories
New-Item -ItemType "Directory" -Path $userHomeDir
New-Item -ItemType "Directory" -Path $userScanDir

#Get current ACL for home dir 
$newUserHomeAcl = Get-Acl -Path $userHomeDir
#Apply new ACL rule for home dir
$newUserHomeAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path $userHomeDir -AclObject $newUserHomeAcl

#Get current ACL for scan dir 
$newUserScanAcl = Get-Acl -Path $userScanDir
#Apply new ACL rule for scan dir
$newUserScanAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path $userScanDir -AclObject $newUserScanAcl

#Removes active PSSessions and clears saved creds
Remove-PSSession $sessionExchange,$sessionAADSync
$UserCredential = ''
