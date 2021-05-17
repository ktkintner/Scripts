<#
This script will prompt for the user to input the username of an existing user to copy the groups from and 
for the username of a user to copy those groups to. 
#>

#User you are copying the groups from
$copyUser = Read-Host -Prompt 'Enter the username of the user you would like to copy the groups from: '
#User you are copying the groups to
$newUser = Read-Host -Prompt 'Enter the username of the user you would like to copy the groups to: '

$groups = (Get-ADUser $copyUser -Properties MemberOf).MemberOf | get-adgroup
$groups = ($groups).samaccountname

foreach ( $item in $groups ) {
    add-adgroupmember -identity $item -members $copyUser
}

#Clear stored variables
$copyUser = ''
$newUser = ''
$groups = ''