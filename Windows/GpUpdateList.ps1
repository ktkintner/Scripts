$cn = Read-Host -Prompt 'Enter the computers you would like to update separated by commas: '
$cred = Get-Credential
$session = New-PSSession -ComputerName $cn.name -cred $cred
Invoke-Command -Session $session -ScriptBlock {gpupdate /force}
Invoke-Command -Session $session -ScriptBlock {Get-EventLog -LogName system -InstanceId1502 -Newest 1}
Remove-PSSession -ComputerName $cn.name
$cred = ''