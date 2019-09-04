[CmdletBinding()]
param(
    [string]$wkdir,
    [ValidateSet('vpn', 'proxy')]
    [string]$product = 'VPN',
    [string]$version,
    [string]$forceUpdate = '0',
    [string]$installerOutDir
)

if ($product -eq 'vpn') {$productID = '73e17130-2a1d-4f7d-97a8-93a9aaa6f10d'}
if ($product -eq 'proxy') {$productID = '881da45b-ce8c-46bf-943d-730e9cee5740'}

if (-not $installerOutDir) {
    $installerOutDir = "$wkdir\project\out\$($product.tolower())_win"
}

try {Get-Command "builder-cli.exe" | Out-Null} 
    catch {
        Write-Error "builder-cli.exe of BitRock installer not found in %PATH%. Please, resolve"
        exit 1
    }

if ($version) {
        Invoke-Expression "builder-cli.exe build $wkdir\project\Privatix.xml windows --setvars project.version=$version product_id=$productID product_name=$product forceUpdate=$forceUpdate project.outputDirectory=$installerOutDir"
    } else {
        Write-Warning "no version specified for installer"
        Invoke-Expression "builder-cli.exe build $wkdir\project\Privatix.xml windows --setvars project.version=undefined product_id=$productID product_name=$product forceUpdate=$forceUpdate project.outputDirectory=$installerOutDir"
    }