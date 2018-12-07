<#
.SYNOPSIS
    Gather logs, config nad DB dump on Windows
.DESCRIPTION
    Gather logs, config nad DB dump on Windows. 
    Makes folder "dump" and places all logs, configs and DB dump in it. 
    Creates zip archive.

.PARAMETER installDir
    Root application folder. E.g. "C:\Program Files\Privatix\Agent"

.EXAMPLE
    .\new-dump.ps1 -installDir "C:\build\1205_1836\client\"

    Description
    -----------
    Gather logs, configs and DB dump. Create folder "dump" inside installation directory and place zipped files in archive. 
#>
[cmdletbinding()]
param(
    [ValidateScript( {Test-Path $_ })]
    [string]$installDir
)
$PGdump = Join-Path -Path $installDir -ChildPath "pgsql\bin\pg_dump.exe" -Resolve
$CoreLog = Join-Path -Path $installDir -ChildPath "log" -Resolve
$ProdLog = Join-Path -Path $installDir -ChildPath "product\73e17130-2a1d-4f7d-97a8-93a9aaa6f10d\log" -Resolve
$dappctrlconf = Join-Path -Path $installDir -ChildPath "dappctrl\dappctrl.config.json" -Resolve
$dappguiSettingsJson = Join-Path -Path $installDir -ChildPath "dappgui\resources\app\build\settings.json" -Resolve
$dappguiPackageJson = Join-Path -Path $installDir -ChildPath "dappgui\resources\app\build\package.json" -Resolve
$ProdConf = Join-Path -Path $installDir -ChildPath "product\73e17130-2a1d-4f7d-97a8-93a9aaa6f10d\config" -Resolve
$DBconf = (Get-Content $dappctrlconf | ConvertFrom-Json).DB.conn 
if ($DBconf.password) {$env:PGPASSWORD = $DBconf.password}
$connstr = "host=$($DBconf.host) dbname=$($DBconf.dbname) user=$($DBconf.user) port=$($DBconf.port)"
$connstr += " sslmode=disable"
$OutFolder = (New-Item -Path "$installDir\dump\$(get-date -Format "MMdd_HHmm")" -ItemType Directory).FullName
New-Item -Path $OutFolder -Name "coreconfig" -ItemType Directory -Force | Out-Null
Invoke-Expression "$PGdump -C --column-inserts -d dappctrl -h 127.0.0.1 -p 5433 -U postgres -f `"$OutFolder\dbdump$(get-date -Format "MMdd_HHmm").sql`""
Copy-Item -Path $CoreLog -Destination "$OutFolder\corelog" -Recurse -Force
Copy-Item -Path $ProdLog -Destination "$OutFolder\prodlog" -Recurse -Force
Copy-Item -Path $dappctrlconf -Destination "$OutFolder\coreconfig\dappctrl.config.json"  -Force
Copy-Item -Path $dappguiSettingsJson -Destination "$OutFolder\coreconfig\settings.json" -Force
Copy-Item -Path $dappguiPackageJson -Destination "$OutFolder\coreconfig\package.json" -Force
Copy-Item -Path $ProdConf -Destination "$OutFolder\prodconfig" -Recurse -Force
add-type -AssemblyName System.IO.Compression.FileSystem
$zipDestinationFolder = (Get-Item $OutFolder).Parent.FullName
$zipDestinationFile = Join-Path -Path $zipDestinationFolder -ChildPath ((Get-Item $OutFolder).Name + "dump.zip")
[System.IO.Compression.ZipFile]::CreateFromDirectory($OutFolder, $zipDestinationFile, 'Optimal', $false)
