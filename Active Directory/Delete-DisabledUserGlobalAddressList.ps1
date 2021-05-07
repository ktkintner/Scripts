#This script deletes disabled users from the Global address list. 

#Before running you need to enter your Exchange server's information in the -ConnectionUri where the PSSession is defined

#Requests user input their creds so they can be stored securly while the script is executed
$userCredential = Get-Credential

#ask user what OU they want to search
$ouToSearch = Read-Host -Prompt 'Enter the OU you would like to search:'

#Opens PSSessions to Exchange so commands can be run locally - enter your Exchange server here
$sessionExchange = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://Exchange.YourDomain.com/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $sessionExchange -DisableNameChecking

#Finds all disabled users in the OU Site Avalon that are still in the global address list and removes them
Get-ADUser `
 -Filter {(enabled -eq "false") -and (msExchHideFromAddressLists -notlike "*")} `
 -SearchBase $ouToSearch
 -Properties SamAccountName,enabled,msExchHideFromAddressLists | `
 Set-ADUser -Add @{msExchHideFromAddressLists="TRUE"}

#Removes active PSSessions and clears saved creds
Remove-PSSession $sessionExchange
$UserCredential = ''
