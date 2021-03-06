<#
Script will GPUpdate /force a single computer or list of computers, script prompts for computer or you can
enter multiple computers by separating multiple computer names with a comma ',' between each
#>

$cn = Read-Host -Prompt 'Enter the computers you would like to update separated by commas: '
$cred = Get-Credential
$session = New-PSSession -ComputerName $cn.name -cred $cred
Invoke-Command -Session $session -ScriptBlock {gpupdate /force}
Invoke-Command -Session $session -ScriptBlock {Get-EventLog -LogName system -InstanceId1502 -Newest 1}
Remove-PSSession -ComputerName $cn.name
$cred = ''