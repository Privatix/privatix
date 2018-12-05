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

.PARAMETER clean
    Can be: "nothing","binaries", "all".
    Nothing - do not remove anything before build.
    Binaries - remove only project binaries form $gopath\bin
    All - remove binaries and all repos from $gopath\src\github.com\privatix

.PARAMETER installer
    Run BitRock installer to get packed installer. Requires "pack" flag to be set. 

.EXAMPLE
    .\publish-dapp.ps1 -wkdir "C:\build" -staticArtefactsDir "C:\static_art"

    Description
    -----------
    Build application from develop branches. 

.EXAMPLE
    .\publish-dapp.ps1 -wkdir "C:\build" -staticArtefactsDir "C:\static_art" -clean all

    Description
    -----------
    Same as above, but deletes all project binaries frreom gopath.
    Additionally it deletes folder in gopath\src\github.com\privatix.
    Build application from develop branches. 

.EXAMPLE
    .\publish-dapp.ps1 -staticArtefactsDir "C:\static_art" -pack -godep -gitpull -Verbose

    Description
    -----------
    Build application. Package it, so it can be installed, using installer.
    Checkout "develop" branch for each component. Pull latest commints from git. Run go dependecy.
    Place result in default location %SystemDrive%\build\<date-time>\

.EXAMPLE
    .\publish-dapp.ps1 -staticArtefactsDir "C:\privatix\art" -pack -godep -gitpull -dappguibranch "master" -dappctrlbranch "master" -dappinstbranch "master" -dappopenvpnbranch "master"

    Description
    -----------
    Same as above, but "master" branch is used for all components.
    
#>
[CmdletBinding()]
param(
    [string]$wkdir,
    [ValidateScript( {Test-Path $_ })]
    [string]$staticArtefactsDir = "c:\privatix\art",
    [ValidateSet('nothing', 'binaries', 'all')]
    [string]$clean = 'nothing',
    [switch]$gitpull,
    [switch]$godep,
    [switch]$pack,
    [switch]$installer,
    [string]$dappguibranch = "develop",
    [string]$dappctrlbranch = "develop",
    [string]$dappinstbranch = "develop",
    [string]$dappopenvpnbranch = "develop"
    
)
if (-not $PSBoundParameters.ContainsKey('wkdir')) {
    $wkdir = $($ENV:SystemDrive) + "\build\" + (Get-Date -Format "MMdd_hhmm")
}

if ($PSBoundParameters.ContainsKey('installer')) {
    $pack = $true
}

if ($PSBoundParameters.ContainsKey('Verbose')) {
    $global:VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
}

if (($clean -eq 'binaries') -or ($clean -eq 'all')) {
    try {
        Write-Verbose "Removing binaries..."
        .\remove-binaries.ps1
    } 
    catch {Write-Warning "Some error occured during binaries cleanup. Original error: $($error[0].Exception)"}
}

if ($clean -eq 'all') {
    try {
        $gopath = $ENV:GOPATH
        $privatixDir = "$gopath\src\github.com\privatix"
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
. $builddapp -dappctrl -branch $dappctrlbranch -gitpull:$gitpull -godep:$godep
$TotalTime += $sw.Elapsed.TotalSeconds
Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green

$sw.Restart()
. $builddapp -dappopenvpn -branch $dappopenvpnbranch -gitpull:$gitpull -godep:$godep
$TotalTime += $sw.Elapsed.TotalSeconds
Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green

$sw.Restart()
. $builddapp -dappinstaller -branch $dappinstbranch -gitpull:$gitpull -godep:$godep
$TotalTime += $sw.Elapsed.TotalSeconds
Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green

if ($pack) {
    $sw.Restart()
    . $builddapp -dappgui -branch $dappguibranch -gitpull:$gitpull -wd $wkdir -package
    $TotalTime += $sw.Elapsed.TotalSeconds
    Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green

    $sw.Restart()
    if ($installer) {
        try {Get-Command "builder-cli.exe" | Out-Null} 
        catch {
            Write-Error "builder-cli.exe of BitRock installer not found in %PATH%. Please, resolve"
            exit 1
        }
        new-package -wrkdir $wkdir -staticArtefactsDir $staticArtefactsDir -installer
        Invoke-Expression "builder-cli.exe build $wkdir\project\Privatix.xml windows" 
    }
    else {
        new-package -wrkdir $wkdir -staticArtefactsDir $staticArtefactsDir
    }
    $TotalTime += $sw.Elapsed.TotalSeconds
    Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green
}
else {
    $sw.Restart()
    . $builddapp -dappgui -branch $dappguibranch -gitpull:$gitpull -wd $wkdir -shortcut
    $TotalTime += $sw.Elapsed.TotalSeconds
    Write-Host "It took $($sw.Elapsed.TotalSeconds) seconds to complete" -ForegroundColor Green
}
Remove-Module new-package

Write-Host "Total execution time: $TotalTime seconds" -ForegroundColor Green
Write-Host "Resulting folder: $wkdir" -ForegroundColor DarkMagenta