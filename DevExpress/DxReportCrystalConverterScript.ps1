<#
You need to set four variables in the script before running it:

$CrystalReportSource
This is the location for your source Crystal files, this can be the top level where all of your 
Crystal reports are stored as the script will recurse through the folder structure.

$DxReportDestBase
This is the base folder for your converted DevExpress reports, the subfolders will match the folder structure
from your Crystal report source folder

$DxRptConvExe
This is the full path including the executable of the DevExpress Reports command line utility for converting

$LogFile 
This is the full path including the name of the txt file of the overall log file for the conversion process
each individual conversion will still have an individual log fill. 
#>

#This is the full path including the executable of the DevExpress Reports command line utility for converting
$DxRptConvExe = ""

<#This is the full path including the name of the txt file of the overall log file for the conversion process
each individual conversion will still have an individual log fill. #>
$LogFile = ""
$CrystalConversions = Get-ChildItem -Path $CrystalReportSource -Include '*.rpt' -recurse | Select-Object -Property PSChildName, BaseName, Directory, FullName

ForEach ($report in $CrystalConversions) {
    <#This is the location for your source Crystal files, this can be the top level where all of your 
    Crystal reports are stored as the script will recurse through the folder structure. #>
    $CrystalReportSource = ""
    <#This is the base folder for your converted DevExpress reports, the subfolders will match the folder structure
    from your Crystal report source folder #>
    $DxReportDestBase = ""
    $CrystalReport = $report.PSChildName
    $BaseName = $report.BaseName
    $Directory = $report.Directory
    $CrystalFullPath = $report.FullName
    $DxReport = $BaseName + ".repx"
    $CrystalReportSource = $CrystalReportSource -Replace "\\", "\\"
    $DxReportDestBase = $DxReportDestBase -Replace "\\", "\\"
    $DxReportDest = $Directory -Replace $CrystalReportSource, $DxReportDestBase
    $DxReportDest = $DxReportDest -Replace "\\\\", "\"
    $DxFullPath = $DxReportDest + "\" + $DxReport
    $ConvLog = $BaseName + "-log.txt"
    $ConvLogFile = $DxReportDest + "\" + $ConvLog

    #Create log file for batch conversion 
    Add-Content $LogFile "---------------------------------------------------------------------------------------"
    Add-Content $LogFile ""
    Add-Content $LogFile ""
    Add-Content $LogFile "Crystal Report being converted: `t "  -NoNewline
    Add-Content $LogFile -Value $CrystalReport
    Add-Content $LogFile "Crystal Report location:        `t " -NoNewline
    Add-Content $LogFile -Value $Directory
    Add-Content $LogFile "New DevExpress Report:          `t " -NoNewline
    Add-Content $LogFile -Value $DxReport
    Add-Content $LogFile "DevExpress location:            `t " -NoNewline
    Add-Content $LogFile -Value $DxReportDest
    Add-Content $LogFile "Report converted at:            `t " -NoNewline
    Add-Content $LogFile -Value (Get-Date) -PassThru -NoNewline
    Add-Content $LogFile ""
    Add-Content $LogFile ""

    #Log file for individual report conversion
    Add-Content $ConvLogFile "Crystal Report being converted: `t "  -NoNewline
    Add-Content $ConvLogFile -Value $CrystalReport
    Add-Content $ConvLogFile "Crystal Report location:        `t " -NoNewline
    Add-Content $ConvLogFile -Value $Directory
    Add-Content $ConvLogFile "New DevExpress Report:          `t " -NoNewline
    Add-Content $ConvLogFile -Value $DxReport
    Add-Content $ConvLogFile "DevExpress location:            `t " -NoNewline
    Add-Content $ConvLogFile -Value $DxReportDest
    Add-Content $ConvLogFile "Report converted at:            `t " -NoNewline
    Add-Content $ConvLogFile -Value (Get-Date) -PassThru -NoNewline
    Add-Content $ConvLogFile ""
    Add-Content $ConvLogFile ""

    $DxRptConvExe /in:$CrystalFullPath /out:$DxFullPath /crystal:UnrecognizedFunctionBehavior=Ignore | Out-File $ConvLogFile -Append
} 