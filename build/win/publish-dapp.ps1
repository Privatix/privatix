<#
.SYNOPSIS
    Build Privatix app, copy artefacts and create deploy archive with installer.
.DESCRIPTION
    Build Privatix artefacts. 
    Copy them to single location. 
    Create deploy folder with installer and app.zip.

.PARAMETER wkdir
    Working directory, where result will be published. It will be created.

.PARAMETER staticArtefactsDir
    Directory with static artefacts (e.g. postgesql, tor, openvpn, visual studio redistributable)

.PARAMETER product
    Which Service plug-in to package. Can be "VPN" or "Proxy". If not specified - VPN product is built.

.PARAMETER dappguibranch
    Git branch to checkout for dappgui build. If not specified "develop" branch will be used.

.PARAMETER dappctrlbranch
    Git branch to checkout for dappctrl build. If not specified "develop" branch will be used.

.PARAMETER dappinstbranch
    Git branch to checkout for dapp-installer build. If not specified "develop" branch will be used.

.PARAMETER dappopenvpnbranch
    Git branch to checkout for dapp-openvpn build. If not specified "develop" branch will be used.

.PARAMETER dappproxybranch
    Git branch to checkout for dapp-proxy build. If not specified "develop" branch will be used.

.PARAMETER privatixbranch
    Git branch to checkout for privatix build. If not specified "develop" branch will be used.

.PARAMETER gitpull
    Make git pull before build.

.PARAMETER clean
    Can be: "nothing","binaries", "all".
    Nothing - do not remove anything before build.
    Binaries - remove only project binaries form $wkdir\bin
    All - remove binaries and all repos from $wkdir\src\github.com\privatix

.PARAMETER installer
    Run BitRock installer to get packed installer. 
    
.PARAMETER version
    If version is specified, it will be passed to Bitrock and Dapp-GUI settings.json -> release.

.PARAMETER dappctrlConf
    Specifes filename of dappctrl config. By default "dappctrl-dev.config.json" is used

.PARAMETER forceUpdate
    If "1", installer will force update, instead of upgrade, meaning only clean install is possible.

.PARAMETER installerOutDir
    Where resulting executable windows installer is placed. If installer option is set.
    
.PARAMETER guiEthNetwork
    Ethereum network to use in GUI. Can be 'rinkeby' or 'mainnet'

.EXAMPLE
    .\publish-dapp.ps1 -wkdir "C:\build" -staticArtefactsDir "C:\static_art"

    Description
    -----------
    Build application from develop branches. 

.EXAMPLE
    .\publish-dapp.ps1 -wkdir "C:\build" -staticArtefactsDir "C:\static_art" -clean all

    Description
    -----------
    Same as above, but deletes all project binaries from gopath\bin.
    Additionally it deletes folder in $wkdir\src\github.com\privatix.
    Build application from develop branches. 

.EXAMPLE
    .\publish-dapp.ps1 -staticArtefactsDir "C:\static_art" -gitpull -Verbose

    Description
    -----------
    Build application. Package it, so it can be installed, using installer.
    Checkout "develop" branch for each component. Pull latest commints from git.
    Place result in default location %SystemDrive%\build\<date-time>\

.EXAMPLE
    .\publish-dapp.ps1 -staticArtefactsDir "C:\privatix\art" -gitpull -dappguibranch "master" -dappctrlbranch "master" -dappinstbranch "master" -dappopenvpnbranch "master" -privatixbranch "master"

    Description
    -----------
    Same as above, but "master" branch is used for all components.

.EXAMPLE
    .\publish-dapp.ps1 -product Proxy -staticArtefactsDir "C:\privatix\art" -installer -version "0.21.0" -gitpull -dappguibranch "master" -dappctrlbranch "master" -dappinstbranch "master" -dappopenvpnbranch "master" -privatixbranch "master" -dappctrlConf "dappctrl.config.json" -guiEthNetwork mainnet

    Description
    -----------
    Same as above, but "proxy" product and Bitrock installer is triggered to create executable installer.
    Note: Bitrock installer should be installed (https://installbuilder.bitrock.com/download-step-2.html) and "builder-cli.exe" added to %PATH%

.EXAMPLE
    .\publish-dapp.ps1 -wkdir "C:\build" -staticArtefactsDir "C:\static_art" -forceUpdate "1"

    Description
    -----------
    Build application from develop branches and restrict upgrade, but clean install only. 

#>
[CmdletBinding()]
param(
    [string]$wkdir,
    [ValidateScript( {Test-Path $_ })]
    [string]$staticArtefactsDir = "c:\privatix\art",
    [ValidateSet('vpn', 'proxy')]
    [string]$product = 'VPN',
    [ValidateSet('nothing', 'binaries', 'all')]
    [string]$clean = 'nothing',
    [switch]$gitpull,
    [switch]$installer,
    [string]$version,
    [ValidateSet('rinkeby', 'mainnet')]
    [string]$guiEthNetwork = "rinkeby",
    [string]$dappguibranch = "develop",
    [string]$dappctrlbranch = "develop",
    [string]$dappinstbranch = "develop",
    [string]$dappopenvpnbranch = "develop",
    [string]$dappproxybranch = "develop",
    [string]$privatixbranch = "develop",
    [string]$dappctrlConf = "dappctrl-dev.config.json",
    [ValidateSet('0', '1')]
    [string]$forceUpdate = '0',
    [string]$installerOutDir
    
)

$ErrorActionPreference = "Stop"

$vers = $version

$env:GO111MODULE="on"

$env:Path += ";$env:GOPATH\bin"
$env:Path += ";C:\Program Files\nodejs"
# Bitrock builder Travis location
$env:Path += ";C:\installbuilder\bin"

$ctrl_conf = $dappctrlConf
$network = $guiEthNetwork

if (-not $PSBoundParameters.ContainsKey('wkdir')) {
    $wkdir = $($ENV:SystemDrive) + "\build\" + (Get-Date -Format "MMdd_HHmm")
}
if (!(Test-Path $wkdir)) {New-Item -Path $wkdir -ItemType Directory | Out-Null}

if (-not $installerOutDir) {
    $installerOutDir = "$wkdir\project\out\$($product.tolower())_win"
}

if ($PSBoundParameters.ContainsKey('Verbose')) {
    $global:VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
}

# Product ID supposed to be unchangable for single product (e.g. VPN)
if ($product -eq 'vpn') {$productID = '73e17130-2a1d-4f7d-97a8-93a9aaa6f10d'}
if ($product -eq 'proxy') {$productID = '881da45b-ce8c-46bf-943d-730e9cee5740'}

if (($clean -eq 'binaries') -or ($clean -eq 'all')) {
    try {
        Write-Verbose "Removing binaries..."
        .\remove-binaries.ps1
    } 
    catch {Write-Warning "Some error occured during binaries cleanup. Original error: $($error[0].Exception)"}
}

if ($clean -eq 'all') {
    try {
        $privatixDir = "$wkdir\src\"
        if (Test-Path $privatixDir) {
            Write-Verbose "Removing $privatixDir folder ..."
            Remove-Item -Path $privatixDir -Recurse -Force -Confirm:$false
        }   
    } 
    catch {Write-Warning "Some error occured during folder cleanup. Original error: $($error[0].Exception)"}
}



$builddapp = (Join-Path $PSScriptRoot build-dapp.ps1 -Resolve -ErrorAction Stop)
Import-Module (Join-Path $PSScriptRoot "new-package.psm1" -Resolve) -ErrorAction Stop -DisableNameChecking

$TotalTime = 0

$sw = [Diagnostics.Stopwatch]::StartNew()
. $builddapp -dappctrl -wd $wkdir -branch $dappctrlbranch -gitpull:$gitpull -version:$vers
$TotalTime += $sw.Elapsed.TotalSeconds
Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green

$sw.Restart()
if ($product -eq 'vpn') {
    . $builddapp -dappopenvpn -wd $wkdir -branch $dappopenvpnbranch -gitpull:$gitpull -version:$vers
}
if ($product -eq 'proxy') {
    . $builddapp -dappproxy -wd $wkdir -branch $dappproxybranch -gitpull:$gitpull -version:$vers
}
$TotalTime += $sw.Elapsed.TotalSeconds
Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green

$sw.Restart()
. $builddapp -dappinstaller -wd $wkdir -branch $dappinstbranch -gitpull:$gitpull -version:$vers
$TotalTime += $sw.Elapsed.TotalSeconds
Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green

$sw.Restart()

if ($installer) {
        
    . $builddapp -dappgui -wd $wkdir -branch $dappguibranch -gitpull:$gitpull -package -version:$vers -guiEthNetwork $network
    $TotalTime += $sw.Elapsed.TotalSeconds
    Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green

    $sw.Restart()
    try {Get-Command "builder-cli.exe" | Out-Null} 
    catch {
        Write-Error "builder-cli.exe of BitRock installer not found in %PATH%. Please, resolve"
        exit 1
    }
    
    new-package -wrkdir $wkdir -staticArtefactsDir $staticArtefactsDir -installer -privatixbranch $privatixbranch -gitpull:$gitpull -dappctrlConf:$ctrl_conf -product:$product

    if ($vers) {
        Invoke-Expression "builder-cli.exe build $wkdir\project\Privatix.xml windows --setvars project.version=$vers product_id=$productID product_name=$product forceUpdate=$forceUpdate project.outputDirectory=$installerOutDir"
    } else {
        Write-Warning "no version specified for installer"
        Invoke-Expression "builder-cli.exe build $wkdir\project\Privatix.xml windows --setvars project.version=undefined product_id=$productID product_name=$product forceUpdate=$forceUpdate project.outputDirectory=$installerOutDir"
    }
}
else {
    . $builddapp -dappgui -wd $wkdir -branch $dappguibranch -gitpull:$gitpull -version:$vers -guiEthNetwork $network
    $TotalTime += $sw.Elapsed.TotalSeconds
    Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green
    
    $sw.Restart()
    new-package -wrkdir $wkdir -staticArtefactsDir $staticArtefactsDir -privatixbranch $privatixbranch -gitpull:$gitpull -dappctrlConf:$ctrl_conf -product:$product
}

$TotalTime += $sw.Elapsed.TotalSeconds
Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green

Remove-Module new-package

Write-Host "Total execution time: $TotalTime seconds" -ForegroundColor Green
Write-Host "Resulting folder: $wkdir" -ForegroundColor Green