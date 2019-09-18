<#
.SYNOPSIS
    Build Privatix app, copy artefacts and create deploy archive with installer.
.DESCRIPTION
    Build Privatix artefacts. 
    Copy them to single location. 
    Create deploy folder with installer and app.zip.

.PARAMETER wkdir
    Working directory, where result will be published. It will be created.

.PARAMETER product
    Which Service plug-in to package. Can be "VPN" or "Proxy". If not specified - VPN product is built.

.PARAMETER dappctrlbranch
    Git branch to checkout for dappctrl build. If not specified "develop" branch will be used.

.PARAMETER dappinstbranch
    Git branch to checkout for dapp-installer build. If not specified "develop" branch will be used.

.PARAMETER dappopenvpnbranch
    Git branch to checkout for dapp-openvpn build. If not specified "develop" branch will be used.

.PARAMETER dappproxybranch
    Git branch to checkout for dapp-proxy build. If not specified "develop" branch will be used.

.PARAMETER gitpull
    Make git pull before build.
    
.PARAMETER version
    If version is specified, it will be passed to Bitrock and Dapp-GUI settings.json -> release.

.PARAMETER forceUpdate
    If "1", installer will force update, instead of upgrade, meaning only clean install is possible.

.PARAMETER installerOutDir
    Where resulting executable windows installer is placed. If installer option is set.

.PARAMETER asjobs
    Run build jobs in parallel.

.EXAMPLE
    .\publish-fastdapp.ps1 -product Proxy  -version "0.21.0" -gitpull -dappctrlbranch "master" -dappinstbranch "master" -dappopenvpnbranch "master" 

    Description
    -----------
    Build go artefacts and gather some of them to single folder. This can be used to get golang binaries fast.

#>
[CmdletBinding()]
param(
    [string]$wkdir,
    [ValidateSet('vpn', 'proxy')]
    [string]$product = 'VPN',
    [switch]$gitpull,
    [string]$version,
    [string]$dappctrlbranch = "develop",
    [string]$dappinstbranch = "develop",
    [string]$dappopenvpnbranch = "develop",
    [string]$dappproxybranch = "develop",
    [string]$defaultBranch,
    [switch]$asjobs
)

$ErrorActionPreference = "Stop"

$TotalTime = 0
$TotalTime = [Diagnostics.Stopwatch]::StartNew()

$jobs = @()

$vers = $version

$env:GO111MODULE="on"

$env:Path += ";$env:GOPATH\bin"

if ($defaultBranch) {$env:GIT_BRANCH_DEFAULT = $defaultBranch}

if (-not $PSBoundParameters.ContainsKey('wkdir')) {
    $wkdir = $($ENV:SystemDrive) + "\build\" + (Get-Date -Format "MMdd_HHmm")
}
if (!(Test-Path $wkdir)) {New-Item -Path $wkdir -ItemType Directory | Out-Null}

if ($PSBoundParameters.ContainsKey('Verbose')) {
    $global:VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
}

# Product ID supposed to be unchangable for single product (e.g. VPN)
if ($product -eq 'vpn') {$productID = '73e17130-2a1d-4f7d-97a8-93a9aaa6f10d'}
if ($product -eq 'proxy') {$productID = '881da45b-ce8c-46bf-943d-730e9cee5740'}


$builddapp = (Join-Path $PSScriptRoot build-dapp.ps1 -Resolve -ErrorAction Stop)
Import-Module (Join-Path $PSScriptRoot "new-fastpackage.psm1" -Resolve) -ErrorAction Stop -DisableNameChecking

$dappctrl_sb = [scriptblock] {. $args[0] -dappctrl -wd $args[1] -branch $args[2] -gitpull:$args[3] -version:$args[4]}

if ($asjobs) {
    $jobs += Start-Job -Name build_dappctrl -ScriptBlock $dappctrl_sb -ArgumentList $builddapp, $wkdir, $dappctrlbranch, $gitpull, $vers
} else {
    Invoke-Command -ScriptBlock $dappctrl_sb -ArgumentList $builddapp, $wkdir, $dappctrlbranch, $gitpull, $vers
}

if ($product -eq 'vpn') {
    $dappopenvpn_sb = [scriptblock] {. $args[0] -dappopenvpn -wd $args[1] -branch $args[2] -gitpull:$args[3] -version:$args[4]}
    if ($asjobs) {
        $jobs += Start-Job -Name build_dappopenvpn -ScriptBlock $dappopenvpn_sb -ArgumentList $builddapp, $wkdir, $dappopenvpnbranch, $gitpull, $vers
    } else {
        Invoke-Command -ScriptBlock $dappopenvpn_sb -ArgumentList $builddapp, $wkdir, $dappopenvpnbranch, $gitpull, $vers
    }

}
if ($product -eq 'proxy') {
    $dappproxy_sb = [scriptblock] {. $args[0] -dappproxy -wd $args[1] -branch $args[2] -gitpull:$args[3] -version:$args[4]}
    if ($asjobs) {
        $jobs += Start-Job -Name build_dappopenvpn -ScriptBlock $dappproxy_sb -ArgumentList $builddapp, $wkdir, $dappproxybranch, $gitpull, $vers
    } else {
        Invoke-Command -ScriptBlock $dappproxy_sb -ArgumentList $builddapp, $wkdir, $dappproxybranch, $gitpull, $vers
    }
}

$dappinstaller_sb = [scriptblock] {. $args[0] -dappinstaller -wd $args[1] -branch $args[2] -gitpull:$args[3] -version:$args[4]}
if ($asjobs) {
    $jobs += Start-Job -Name build_dappinstaller -ScriptBlock $dappinstaller_sb -ArgumentList $builddapp, $wkdir, $dappinstbranch, $gitpull, $vers
} else {
    Invoke-Command -ScriptBlock $dappinstaller_sb -ArgumentList $builddapp, $wkdir, $dappinstbranch, $gitpull, $vers
}


if ($asjobs) {
    Get-Job | Format-Table -AutoSize

    $buidjobsComplete = $false
    [int[]]$UnrepJobsIDs = $null
    while (-not $buidjobsComplete) {
        $jobs = $jobs | Get-Job
        $CompletedJobs = $jobs | Where-Object { ($_.state -eq "Completed") -or ($_.state -eq "Failed")}
        $UnrepJobsIDs = $CompletedJobs.id | Where-Object {$ReportedJobs -notcontains $_}
        if ($UnrepJobsIDs.length -gt 0) {
            foreach ($UnrepJobsID in $UnrepJobsIDs) {
                Get-Job -Id $UnrepJobsID | Select-Object ID, Name, State, @{Name = 'SecondsToComplete'; Expression = {[int]($_.PSEndTime - $_.PSBeginTime).TotalSeconds}}
                $ReportedJobs += $UnrepJobsIDs
            }
        }
        Write-Progress -Activity "Building jobs running..." -PercentComplete $([int]($CompletedJobs.length / $jobs.length * 100)) -CurrentOperation "Completed $($CompletedJobs.length)/$($jobs.length) jobs"
        if ($CompletedJobs.length -eq $jobs.length) {$buidjobsComplete = $true; Write-Progress -Activity "Building jobs running..." -Completed} else {Start-Sleep -Seconds 3}

    }

    foreach ($job in $jobs) {
        $log += "#######################" | Out-String 
        $log += "##### $($job.name) ####" | Out-String 
        $log += "#######################" | Out-String 
        $log += $job | Select-Object -Property * | Format-List | Out-String
        $log += $job | Receive-Job | Out-String
    }

    $log |  Out-File -FilePath "$wkdir\build.log" -Append 
    $log
    Remove-Job $jobs.id -Force
}

new-fastpackage -wrkdir $wkdir -product:$product

Remove-Module new-fastpackage

Write-Host "Total execution time: $($TotalTime.Elapsed.TotalSeconds) seconds" -ForegroundColor Green
Write-Host "Resulting folder: $wkdir" -ForegroundColor Green