<#
.SYNOPSIS
    Gather logs, config and DB dump on Windows
.DESCRIPTION
    Gather logs, config and DB dump on Windows. 
    Makes folder "dump" in installation directory and places all logs, configs and DB dump in it. 
    Creates zip archive.

.PARAMETER installDir
    Root application folder that chosen during setup. E.g. "C:\Program Files\Privatix"

.PARAMETER noComputerLogs
    Do not gather additional info about computer and network. Only application info.

.EXAMPLE
    .\new-dump.ps1 -installDir C:\Program Files\Privatix"

    Description
    -----------
    Gathers logs, configs and DB dump. Creates folder "dump" inside Client and/or Agent subfolder and places zipped files in single archive.
    Gather ipconfig, route, adapter, processes, service and basic OS info.

.EXAMPLE
    .\new-dump.ps1 -installDir C:\Program Files\Privatix" -NoComputerLogs

    Description
    -----------
    Gathers only application data, without ipconfig, route, adapter, processes, service and basic OS info.
#>
[cmdletbinding()]
param(
    [string]$installDir = "C:\Program Files\Privatix",
    [switch]$noComputerLogs
)

function Flatten($arr) {
    , @($arr | ForEach-Object {$_})
}

function create-dump {
    <#
.SYNOPSIS
    Gather logs, config and DB dump on Windows
.DESCRIPTION
    Gather logs, config and DB dump on Windows. 
    Makes folder "dump" in installation directory and places all logs, configs and DB dump in it. 
    Creates zip archive.

.PARAMETER installDir
    Client or Agent application folder. E.g. "C:\Program Files\Privatix\Agent"

.PARAMETER computerLogs
    Gather additional info about computer and network

.EXAMPLE
    .\new-dump.ps1 -installDir C:\Program Files\Privatix\Agent"

    Description
    -----------
    Gathers logs, configs and DB dump. Creates folder "dump" inside installation directory and places zipped files in single archive.

.EXAMPLE
    .\new-dump.ps1 -installDir C:\Program Files\Privatix\client" -computerLogs

    Description
    -----------
    ame as above, but also creates folder "computerLogs" and gather ip, route, adapter, processes, service and OS info.
#>
    [cmdletbinding()]
    param(
        [ValidateScript( {Test-Path $_ })]
        [string]$installDir,
        [switch]$computerLogs
    )
    # Root install artefacts
    $rootDir = Split-Path -Path $installDir -Parent 
    $version = Join-Path -Path $rootDir -ChildPath "version" -Resolve
    $dappinstallerconfig = Join-Path -Path $rootDir -ChildPath "dapp-installer.config.json" -Resolve
    $rootLogs = (Get-ChildItem -Path $rootDir -Filter "*.log").FullName
    $rootItemsNested = @($version, $dappinstallerconfig, $rootLogs)
    $rootItems = Flatten($rootItemsNested)

    # Artefacts
    $PGdump = Join-Path -Path $installDir -ChildPath "pgsql\bin\pg_dump.exe" -Resolve
    $CoreLog = Join-Path -Path $installDir -ChildPath "log" -Resolve
    $ProdLog = Join-Path -Path $installDir -ChildPath "product\73e17130-2a1d-4f7d-97a8-93a9aaa6f10d\log" -Resolve
    $coreEnv = Join-Path -Path $installDir -ChildPath ".env.config.json" -Resolve
    $dappctrlconf = Join-Path -Path $installDir -ChildPath "dappctrl\dappctrl.config.json" -Resolve
    $dappguiSettingsJson = Join-Path -Path $installDir -ChildPath "dappgui\resources\app\settings.json" -Resolve
    $dappguiPackageJson = Join-Path -Path $installDir -ChildPath "dappgui\resources\app\package.json" -Resolve
    $ProdConf = Join-Path -Path $installDir -ChildPath "product\73e17130-2a1d-4f7d-97a8-93a9aaa6f10d\config" -Resolve
    # DB dump
    $DBconf = (Get-Content $dappctrlconf | ConvertFrom-Json).DB.conn 
    if ($DBconf.password) {$env:PGPASSWORD = $DBconf.password}
    $OutFolder = (New-Item -Path "$installDir\dump\$(get-date -Format "MMdd_HHmm")" -ItemType Directory).FullName
    Invoke-Expression ".`"$PGdump`" --create --column-inserts --clean --if-exists -d $($DBconf.dbname) -h $($DBconf.host) -p $($DBconf.port) -U $($DBconf.user) -f `"$OutFolder\dbdump$(get-date -Format "MMdd_HHmm").sql`""
    
    # Copy root artefacts
    New-Item -Path $OutFolder -Name "rootinstall" -ItemType Directory -Force | Out-Null
    Copy-Item -Path $rootItems -Destination "$OutFolder\rootinstall" 
    
    # Copy artefacts
    New-Item -Path $OutFolder -Name "coreconfig" -ItemType Directory -Force | Out-Null
    Copy-Item -Path $CoreLog -Destination "$OutFolder\corelog" -Recurse -Force
    Copy-Item -Path $ProdLog -Destination "$OutFolder\prodlog" -Recurse -Force
    Copy-Item -Path $coreEnv -Destination "$OutFolder\coreconfig\.env.config.json" -Force
    Copy-Item -Path $dappctrlconf -Destination "$OutFolder\coreconfig\dappctrl.config.json"  -Force
    Copy-Item -Path $dappguiSettingsJson -Destination "$OutFolder\coreconfig\settings.json" -Force
    Copy-Item -Path $dappguiPackageJson -Destination "$OutFolder\coreconfig\package.json" -Force
    Copy-Item -Path $ProdConf -Destination "$OutFolder\prodconfig" -Recurse -Force

    # Gather additional computer info
    if ($PSBoundParameters.ContainsKey('computerLogs')) {
        $NetFolder = (New-Item -Path "$OutFolder" -Name "computerLogs" -ItemType Directory -Force).FullName
        # Network
        Get-NetRoute | Export-Csv -Path "$NetFolder\route.csv" -NoTypeInformation
        Get-NetAdapter -IncludeHidden | Export-Csv -Path "$NetFolder\adapter.csv" -NoTypeInformation
        Get-NetIPConfiguration -All -Detailed | Out-File -FilePath "$NetFolder\netconfig.txt"
        # Service
        Get-Service -Name "*privatix*", "*postgres*" | Export-Csv -Path "$NetFolder\serviceShort.csv" -NoTypeInformation
        Get-Service | Export-Csv -Path "$NetFolder\service.csv" -NoTypeInformation
        Get-WmiObject -Class win32_service | Where-Object {$_.Name -match "privatix"} | Export-Csv -Path "$NetFolder\serviceShort.csv" -NoTypeInformation
        Get-WmiObject -Class win32_service | Export-Csv -Path "$NetFolder\serviceExtended.csv" -NoTypeInformation
        # Process
        Get-Process -Name "*privatix*", "*dapp*", "*postgres*", "*openvpn*" | Export-Csv -Path "$NetFolder\processShort.csv" -NoTypeInformation
        Get-Process | Export-Csv -Path "$NetFolder\process.csv" -NoTypeInformation
        Get-WmiObject -Class win32_process | Where-Object {$_.Name -match "privatix" -or $_.Name -match "dapp" -or $_.Name -match "openvpn" } | Export-Csv -Path "$NetFolder\processShort.csv" -NoTypeInformation
        Get-WmiObject -Class win32_process | Export-Csv -Path "$NetFolder\processExtended.csv" -NoTypeInformation
        # General OS info
        Get-ComputerInfo | Export-Csv -Path "$NetFolder\computerinfo.csv" -NoTypeInformation
    }

    # Create archive
    add-type -AssemblyName System.IO.Compression.FileSystem
    $zipDestinationFolder = (Get-Item $OutFolder).Parent.FullName
    $zipDestinationFile = Join-Path -Path $zipDestinationFolder -ChildPath ((Get-Item $OutFolder).Name + "dump.zip")
    [System.IO.Compression.ZipFile]::CreateFromDirectory($OutFolder, $zipDestinationFile, 'Optimal', $false)
    Write-Host "Dump is located here: $zipDestinationFile" -ForegroundColor Green

    # Remove source folder
    if (Test-Path $OutFolder) {
        Remove-Item $OutFolder -Recurse -Force
    }
}


# Check install path exists
$clientDir = Join-Path -Path $installDir -ChildPath "client" -Resolve -ErrorAction SilentlyContinue
$agentDir = Join-Path -Path $installDir -ChildPath "agent" -Resolve -ErrorAction SilentlyContinue

$installationDirs = @($clientDir, $agentDir) | Where-Object {$_}

foreach ($installDir in $installationDirs) {
    if ($noComputerLogs.IsPresent) {
        create-dump -installDir $installDir
    }
    else {
        create-dump -installDir $installDir -computerLogs
    }
}
