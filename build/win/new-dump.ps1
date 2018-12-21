<#
.SYNOPSIS
    Gather logs, config and DB dump on Windows
.DESCRIPTION
    Gather logs, config and DB dump on Windows. 
    Makes folder "dump" and places all logs, configs and DB dump in it. 
    Creates zip archive.

.PARAMETER installDir
    Root application folder. E.g. "C:\Program Files\Privatix\Agent"

.PARAMETER networkLogs
    Gather additional info about computer and network

.EXAMPLE
    .\new-dump.ps1 -installDir "C:\build\1205_1836\client\"

    Description
    -----------
    Gathers logs, configs and DB dump. Creates folder "dump" inside installation directory and places zipped files in single archive.

.EXAMPLE
    .\new-dump.ps1 -installDir "C:\build\1205_1836\client\" -networkLogs

    Description
    -----------
    Same as above, but also creates folder "network" and gather route, adapter, etc.
#>
[cmdletbinding()]
param(
    [ValidateScript( {Test-Path $_ })]
    [string]$installDir,
    [switch]$networkLogs
)
$PGdump = Join-Path -Path $installDir -ChildPath "pgsql\bin\pg_dump.exe" -Resolve
$CoreLog = Join-Path -Path $installDir -ChildPath "log" -Resolve
$ProdLog = Join-Path -Path $installDir -ChildPath "product\73e17130-2a1d-4f7d-97a8-93a9aaa6f10d\log" -Resolve
$coreEnv = Join-Path -Path $installDir -ChildPath ".env.config.json" -Resolve
$dappctrlconf = Join-Path -Path $installDir -ChildPath "dappctrl\dappctrl.config.json" -Resolve
$dappguiSettingsJson = Join-Path -Path $installDir -ChildPath "dappgui\resources\app\settings.json" -Resolve
$dappguiPackageJson = Join-Path -Path $installDir -ChildPath "dappgui\resources\app\package.json" -Resolve
$ProdConf = Join-Path -Path $installDir -ChildPath "product\73e17130-2a1d-4f7d-97a8-93a9aaa6f10d\config" -Resolve
$DBconf = (Get-Content $dappctrlconf | ConvertFrom-Json).DB.conn 
if ($DBconf.password) {$env:PGPASSWORD = $DBconf.password}
$OutFolder = (New-Item -Path "$installDir\dump\$(get-date -Format "MMdd_HHmm")" -ItemType Directory).FullName
New-Item -Path $OutFolder -Name "coreconfig" -ItemType Directory -Force | Out-Null
Invoke-Expression ".`"$PGdump`" --create --column-inserts --clean --if-exists -d $($DBconf.dbname) -h $($DBconf.host) -p $($DBconf.port) -U $($DBconf.user) -f `"$OutFolder\dbdump$(get-date -Format "MMdd_HHmm").sql`""
Copy-Item -Path $CoreLog -Destination "$OutFolder\corelog" -Recurse -Force
Copy-Item -Path $ProdLog -Destination "$OutFolder\prodlog" -Recurse -Force
Copy-Item -Path $coreEnv -Destination "$OutFolder\coreconfig\.env.config.json" -Force
Copy-Item -Path $dappctrlconf -Destination "$OutFolder\coreconfig\dappctrl.config.json"  -Force
Copy-Item -Path $dappguiSettingsJson -Destination "$OutFolder\coreconfig\settings.json" -Force
Copy-Item -Path $dappguiPackageJson -Destination "$OutFolder\coreconfig\package.json" -Force
Copy-Item -Path $ProdConf -Destination "$OutFolder\prodconfig" -Recurse -Force
add-type -AssemblyName System.IO.Compression.FileSystem
$zipDestinationFolder = (Get-Item $OutFolder).Parent.FullName
$zipDestinationFile = Join-Path -Path $zipDestinationFolder -ChildPath ((Get-Item $OutFolder).Name + "dump.zip")
[System.IO.Compression.ZipFile]::CreateFromDirectory($OutFolder, $zipDestinationFile, 'Optimal', $false)

if ($PSBoundParameters.ContainsKey('networkLogs')) {
    $NetFolder = (New-Item -Path "$OutFolder" -Name "network" -ItemType Directory -Force).FullName
    Get-NetRoute | Export-Csv -Path "$NetFolder\route.csv" -NoTypeInformation
    Get-NetAdapter -IncludeHidden | Export-Csv -Path "$NetFolder\adapter.csv" -NoTypeInformation
    Get-NetIPConfiguration -All -Detailed | Out-File -FilePath "$NetFolder\netconfig.log"
    Get-ComputerInfo | Export-Csv -Path "$NetFolder\computerinfo.csv" -NoTypeInformation
}
