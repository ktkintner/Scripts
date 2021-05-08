<#
This script can be used to merge Hyper-V differencing disks together (AVHDX file extensions) when 
they fail to automatically merge, this can be easily done if you catch it when there are only a few. 
But, when you have 100-200 or more it's a huge, time consuming process to find the last AVHDX file, 
merge it, then continue repeating the process. Done by hand, it can take days or weeks, as it requires 
downtime, since the VM must be offline. To solve tihs problem, I wrote this script to do the work for me. 
#>



#These are the variables that need to be defined for your environment and for each run
$vmHost = "yourVMHost"
$vmName = "yourVM"
$controllerLocation = 0
$mergeLog = "c:\temp\logfile"

#defining a loop counter for the while statement
$loopCount = 0

Clear-Host

Write-Host "Gathering a list of VHD files before we start merging please be patient."
Write-Host "If you have a lot of VHD files that need to be merged this could take several minutes."

#gets the current VHD and its parent
$path = (Get-VMHardDiskDrive -ComputerName $vmHost -VMName $vmName -ControllerLocation $controllerLocation).path
$parentPath = (Get-VHD -Path $path).ParentPath

#gets a full list of all VHDs that need to merged
$vhdList = while($path = (get-vhd -path $path).parentpath) {$path}

#Create log file for merge
Add-Content $mergeLog "---------------------------------------------------------------------------------------"
Add-Content $mergeLog ""
Add-Content $mergeLog ""
Add-Content $mergeLog "List of all VHD files to be merged on " -NoNewline
Add-Content $mergeLog -Value (Get-Date) -PassThru
Add-Content $mergeLog -Value $vhdList
Add-Content $mergeLog ""
Add-Content $mergeLog ""
Add-Content $mergeLog "---------------------------------------------------------------------------------------"



foreach ($item in $vhdList) {
    
	$path = $item
    $parentPath = (Get-VHD -Path $path).ParentPath
	
	If ( $parentPath -ne '' ) {
        Write-Host "Merging VHDs"
        Write-Host "Attempting to"
        Write-Host "Merge :" $path 
        Write-Host "Into :" $parentPath

        Merge-VHD -Path $path -Force

        #Log file entry for individual merge
        Add-Content $mergeLog "Merged: `t "  -NoNewline
        Add-Content $mergeLog -Value $path
        Add-Content $mergeLog "Into:   `t " -NoNewline
        Add-Content $mergeLog -Value $parentPath
        Add-Content $mergeLog "At:     `t " -NoNewline
        Add-Content $mergeLog -Value (Get-Date) -PassThru -NoNewline
        Add-Content $mergeLog ""
        Add-Content $mergeLog ""
        
        #Updating loop count and writing message to terminal
        $loopCount++
        Write-Host "VHDs merged: " $loopCount
        Write-Host ""
        Write-Host ""
    }
}
If ( $loopCount -gt 0 ) {
    Write-Host "Merge complete! Total files merged: " $loopCount
}
Else {
    Write-Host "No files to merge. Please recheck variable info for: VM Host, VM Name, and Controller Location (for disk)."
}
