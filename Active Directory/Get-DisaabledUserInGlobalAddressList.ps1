#This script finds disabled users that are still listed in the global address list.

#Before running you need to enter your Exchange server's information in the -ConnectionUri where the PSSession is defined

#Requests user input their creds so they can be stored securly while the script is executed
$userCredential = Get-Credential

#ask user what OU they want to search
$ouToSearch = Read-Host -Prompt 'Enter the OU you would like to search:'

#Opens PSSessions to Exchange so commands can be run locally - enter your Exchange server here
$sessionExchange = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://Exchange.YourDomain.com/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $sessionExchange -DisableNameChecking

Get-ADUser `
 -Filter {(enabled -eq "false") -and (msExchHideFromAddressLists -notlike "*")} `
 -SearchBase $ouToSearch
 -Properties enabled,msExchHideFromAddressLists | Format-Table

#Removes active PSSessions and clears saved creds
Remove-PSSession $sessionExchange
$UserCredential = ''
