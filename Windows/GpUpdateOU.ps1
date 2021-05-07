<#
Script will GPUpdate /force an OU, script prompts for the OU 
#>

$ouToSearch = Read-Host -Prompt 'Enter the OU you would like to update: '
$cn = Get-ADComputer -filter * -SearchBase $ouToSearch
$cred = Get-Credential
$session = New-PSSession -ComputerName $cn.name -cred $cred
Invoke-Command -Session $session -ScriptBlock {gpupdate /force}
Invoke-Command -Session $session -ScriptBlock {Get-EventLog -LogName system -InstanceId1502 -Newest 1}
Remove-PSSession -ComputerName $cn.name
$cred = ''