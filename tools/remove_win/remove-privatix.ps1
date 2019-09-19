#Requires -RunAsAdministrator

#TODO: Implement TAP Driver and FW rules removal for Agent.

# Remove all services
Get-Service | ? {$_.name -match "privatix" -and $_.name -notmatch "PrivatixService"} | Stop-Service -PassThru -ErrorAction SilentlyContinue | % {sc.exe delete $_.name}
# Find uninstall entries in registry 
$UninstallRegistryItems = Get-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Privatix Network*"
# For each unsinstall registry entry remove install folder and registry item
ForEach ($UninstallRegistryItem in $UninstallRegistryItems) { 
    $RemoveItem = $true
    $InstallLocation = ($UninstallRegistryItem | Get-ItemProperty -PSProperty InstallLocation).InstallLocation
        Write-Host "Removing $InstallLocation ..."
        $userInput = Read-Host -Prompt "[y/n]"
        if ($userInput.ToLower() -eq "y") {
            try {
                if (Test-Path $InstallLocation) {
                    Remove-Item -Recurse -Force -Path $InstallLocation
                }
            }
            catch {
                $RemoveItem = $false
                Write-Error "Failed to remove $InstallLocation. Original exception: $($error[0].exception)"
            }
            if ($RemoveItem) {
                Write-Host "Removing $UninstallRegistryItem ..."
                $UninstallRegistryItem | Remove-Item
            }
        }
}


