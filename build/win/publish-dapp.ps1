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

.PARAMETER pack
    If to package application additionaly to just building components.

.PARAMETER dappguibranch
    Git branch to checkout for dappgui build. If not specified "develop" branch will be used.

.PARAMETER dappctrlbranch
    Git branch to checkout for dappctrl build. If not specified "develop" branch will be used.

.PARAMETER dappinstbranch
    Git branch to checkout for dapp-installer build. If not specified "develop" branch will be used.

.PARAMETER dappopenvpnbranch
    Git branch to checkout for dapp-openvpn build. If not specified "develop" branch will be used.

.PARAMETER godep
    Run "dep ensure" command for each golang branch. It runs for all of them.

.PARAMETER gitpull
    Make git pull before build.

.EXAMPLE
    build-dappctrl

    Description
    -----------
    Build dappctrl.

.EXAMPLE
    build-dappctrl -branch "develop" -godep -gitpull

    Description
    -----------
    Checkout branch "develop". Pull from git. Run go dependecy. Build dappctrl.
#>
[CmdletBinding()]
param(
    [string]$wkdir = "c:\prix_workdir\",
    [ValidateScript( {Test-Path $_ })]
    [string]$staticArtefactsDir = "c:\privatix\art",
    [switch]$pack,
    [string]$dappguibranch = "develop",
    [string]$dappctrlbranch = "develop",
    [string]$dappinstbranch = "develop",
    [string]$dappopenvpnbranch = "develop",
    [switch]$godep,
    [switch]$gitpull
)
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $global:VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
}


$builddapp = (Join-Path $PSScriptRoot build-dapp.ps1 -Resolve -ErrorAction Stop)
Import-Module (Join-Path $PSScriptRoot "new-package.psm1" -Resolve) -ErrorAction Stop -DisableNameChecking

$TotalTime = 0

$sw = [Diagnostics.Stopwatch]::StartNew()
. $builddapp -dappctrl -branch $dappctrlbranch -gitpull:$gitpull -godep:$godep
$TotalTime += $sw.Elapsed.Seconds
Write-Host "It took $($sw.Elapsed.Seconds) seconds to complete" -ForegroundColor Green

$sw.Restart()
. $builddapp -dappopenvpn -branch $dappopenvpnbranch -gitpull:$gitpull -godep:$godep
$TotalTime += $sw.Elapsed.Seconds
Write-Host "It took $($sw.Elapsed.Seconds) seconds to complete" -ForegroundColor Green

$sw.Restart()
. $builddapp -dappinstaller -branch $dappinstbranch -gitpull:$gitpull -godep:$godep
$TotalTime += $sw.Elapsed.Seconds
Write-Host "It took $($sw.Elapsed.Seconds) seconds to complete" -ForegroundColor Green

if ($pack) {
    $sw.Restart()
    . $builddapp -dappgui -branch $dappguibranch -gitpull:$gitpull -wd $wkdir -package
    $TotalTime += $sw.Elapsed.Seconds
    Write-Host "It took $($sw.Elapsed.Seconds) seconds to complete" -ForegroundColor Green

    $sw.Restart()
    new-package -wrkdir $wkdir -staticArtefactsDir $staticArtefactsDir
    $TotalTime += $sw.Elapsed.Seconds
    Write-Host "It took $($sw.Elapsed.Seconds) seconds to complete" -ForegroundColor Green
}
else {
    $sw.Restart()
    . $builddapp -dappgui -branch $dappguibranch -gitpull:$gitpull -wd $wkdir -shortcut
    $TotalTime += $sw.Elapsed.Seconds
    Write-Host "It took $($sw.Elapsed.Seconds) seconds to complete" -ForegroundColor Green
}
Remove-Module new-package

Write-Host "Total execution time: $TotalTime seconds" -ForegroundColor Green