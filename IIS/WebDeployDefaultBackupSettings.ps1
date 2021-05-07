<#
This script is a basic script that allows you to set the default settings for backing up IIS sites automatically when using Web Deploy to 
make changes to the site. It could be added to a MDT or SCCM deployment sequence to further simplify. 
#>

# Full documentation for Web Deploy backup: https://docs.microsoft.com/en-us/iis/publish/using-web-deploy/web-deploy-automatic-backups

# Set location as where Web Deploy backup script is located
Set-Location "C:\Program Files\IIS\Microsoft Web Deploy V3\scripts"

# Loads Backup Script provided by Web Deploy
. .\BackupScripts.ps1

# Turns on all backup functionality
TurnOn-Backups -On $true

# Changes default global backup behavior to enabled
Configure-Backups -Enabled $true

# Changes the path of where backups are stored to a sibling directory named "siteName_snapshots".  
# For more information about path variables, see the "backupPath" attribute in the section 
# "Configuring  Backup Settings on the Server for Global usage manually in IIS Config"
Configure-Backups -BackupPath "{SitePathParent}\{siteName}_snapshots"

# Configures default backup limit to 10 backups
Configure-Backups -NumberOfBackups 10

# Configures sync behavior to fail if a sync fails for any reason
Configure-Backups -ContinueSyncOnBackupFailure $false

# Disallows a site administrator to enable backups and set the number of backups at the site level (change to $true to allow)
Configure-BackupSettingsProvider -CanSetEnabled $false -CanSetNumBackups $false

# Disallows a site administrator to control which providers they want to skip in a backup, as 
# well as whether they can continue a sync after a backup failure (change to $true to allow)
Configure-BackupSettingsProvider -CanSetContinueSyncOnBackupFailure $false -CanAddExcludedProviders $false

# Grabs the global default backup settings
Get-BackupSettings

# Grabs a sites-specific backup settings (enable the following command and replace foo with actual site name) 
#Get-BackupSettings -SiteName "foo"