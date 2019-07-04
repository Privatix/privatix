<#
.SYNOPSIS
    Build single component of Privatix application.
.DESCRIPTION
    Build single component of Privatix application. Components:
    - core (aka controller). dappcrtl repo
    - openvpn service plug-in. dapp-openvpn repo
    - installer. dapp-installer repo
    - GUI. dapp-gui repo
    - run local dappctrl DB

.EXAMPLE
    build-dapp.ps1 [-dappctrl] [-branch <string>] [-gitpull] [-wd] [<CommonParameters>]
    build-dapp.ps1 [-dappopenvpn] [-branch <string>] [-gitpull] [-wd] [<CommonParameters>]
    build-dapp.ps1 [-dappinstaller] [-branch <string>] [-gitpull] [-wd] [<CommonParameters>]
    build-dapp.ps1 [-dappgui] [-branch <string>] [-gitpull] [-wd <string>] [-package] [-shortcut] [<CommonParameters>]
    build-dappproxy [[-branch] <string>] [[-wd] <string>] [[-version] <string>] [-gitpull] [<CommonParameters>]
    # local development only
    build-dapp.ps1 [-dappdb] [-dappctrlconf <string>] [-settingSQL <string>] [-schemaSQL <string>] [-dataSQL <string>] [-psqlpath <string>] [<CommonParameters>]

#>
[cmdletbinding(DefaultParameterSetName = 'dappctrl')]
# Build dappctrl
param(
    #component selector parameters
    [Parameter(ParameterSetName = "dappctrl", HelpMessage = "build dappctrl")]
    [switch]$dappctrl,
    [Parameter(ParameterSetName = "dappgui", HelpMessage = "build dappgui")]
    [switch]$dappgui,
    [Parameter(ParameterSetName = "dappinstaller", HelpMessage = "build dapp-installer")]
    [switch]$dappinstaller,
    [Parameter(ParameterSetName = "dappopenvpn", HelpMessage = "build dapp-openvpn")]
    [switch]$dappopenvpn,
    [Parameter(ParameterSetName = "dappproxy", HelpMessage = "build dapp-proxy")]
    [switch]$dappproxy,
    [Parameter(ParameterSetName = "dappdb", HelpMessage = "init database")]
    [switch]$dappdb,
    # common parameters (not always between all components)
    [Parameter(ParameterSetName = "dappctrl", HelpMessage = "git branch")]
    [Parameter(ParameterSetName = "dappgui", HelpMessage = "git branch")]
    [Parameter(ParameterSetName = "dappinstaller", HelpMessage = "git branch")]
    [Parameter(ParameterSetName = "dappopenvpn", HelpMessage = "git branch")]
    [Parameter(ParameterSetName = "dappproxy", HelpMessage = "git branch")]
    [string]$branch,        
    [Parameter(ParameterSetName = "dappctrl", HelpMessage = "git pull")]
    [Parameter(ParameterSetName = "dappinstaller", HelpMessage = "git pull")]
    [Parameter(ParameterSetName = "dappgui", HelpMessage = "git pull")]
    [Parameter(ParameterSetName = "dappopenvpn", HelpMessage = "git pull")]
    [Parameter(ParameterSetName = "dappproxy", HelpMessage = "git pull")]
    [switch]$gitpull,
    [Parameter(ParameterSetName = "dappctrl", HelpMessage = "set version")]
    [Parameter(ParameterSetName = "dappgui", HelpMessage = "set version")]
    [Parameter(ParameterSetName = "dappinstaller", HelpMessage = "set version")]
    [Parameter(ParameterSetName = "dappopenvpn", HelpMessage = "set version")]
    [Parameter(ParameterSetName = "dappproxy", HelpMessage = "set version")]
    [string]$version,
    [Parameter(ParameterSetName = "dappctrl", HelpMessage = "path to where to clone repo")]
    [Parameter(ParameterSetName = "dappgui", HelpMessage = "path to where to clone repo")]
    [Parameter(ParameterSetName = "dappinstaller", HelpMessage = "path to where to clone repo")]
    [Parameter(ParameterSetName = "dappopenvpn", HelpMessage = "path to where to clone repo")]
    [Parameter(ParameterSetName = "dappproxy", HelpMessage = "path to where to clone repo")]
    [string]$wd,
    # dappgui parameters
    [Parameter(ParameterSetName = "dappgui", HelpMessage = "whether to package gui")]
    [switch]$package,
    [Parameter(ParameterSetName = "dappgui", HelpMessage = "ethereum network")]
    [string]$ethNetwork,
    # database parameters
    [Parameter(ParameterSetName = "dappdb", HelpMessage = "dappctrl config file path")]
    [string]$dappctrlconf,
    [Parameter(ParameterSetName = "dappdb", HelpMessage = "settings.sql path")]
    [string]$settingSQL,
    [Parameter(ParameterSetName = "dappdb", HelpMessage = "schema.sql path")]
    [string]$schemaSQL,
    [Parameter(ParameterSetName = "dappdb", HelpMessage = "prod_data.sql path")]
    [string]$dataSQL,
    [Parameter(ParameterSetName = "dappdb", HelpMessage = "psql.exe path")]
    [string]$psqlpath

)

$ErrorActionPreference = "Stop"
Write-Host "Working on $($psCmdlet.ParameterSetName)" -ForegroundColor Green
switch ($psCmdlet.ParameterSetName) {
    "dappctrl" {
        import-module (join-path $PSScriptRoot "build-dappctrl.psm1" -resolve) -DisableNameChecking -ErrorAction Stop -Verbose:$false 
        $PSBoundParameters.Remove($psCmdlet.ParameterSetName) | Out-Null
        build-dappctrl @PSBoundParameters
        Remove-Module "build-dappctrl"
        break
    }
    "dappgui" {
        import-module (join-path $PSScriptRoot "build-dappgui.psm1" -resolve) -DisableNameChecking -ErrorAction Stop -Verbose:$false
        $PSBoundParameters.Remove($psCmdlet.ParameterSetName) | Out-Null
        build-dappgui @PSBoundParameters
        Remove-Module "build-dappgui"
        break
    }
    "dappinstaller" {
        import-module (join-path $PSScriptRoot "build-dappinstaller.psm1" -resolve) -DisableNameChecking -ErrorAction Stop -Verbose:$false
        $PSBoundParameters.Remove($psCmdlet.ParameterSetName) | Out-Null
        build-dappinstaller @PSBoundParameters
        Remove-Module "build-dappinstaller"
        break
    }
    "dappopenvpn" {
        import-module (join-path $PSScriptRoot "build-dappopenvpn.psm1" -resolve) -DisableNameChecking -ErrorAction Stop -Verbose:$false
        $PSBoundParameters.Remove($psCmdlet.ParameterSetName) | Out-Null
        build-dappopenvpn @PSBoundParameters
        Remove-Module "build-dappopenvpn"
        break
    }
    "dappproxy" {
        import-module (join-path $PSScriptRoot "build-dappproxy.psm1" -resolve) -DisableNameChecking -ErrorAction Stop -Verbose:$false
        $PSBoundParameters.Remove($psCmdlet.ParameterSetName) | Out-Null
        build-dappproxy @PSBoundParameters
        Remove-Module "build-dappproxy"
        break
    }
    "dappdb" {
        import-module (join-path $PSScriptRoot "deploy-dappdb.psm1" -resolve) -DisableNameChecking -ErrorAction Stop -Verbose:$false
        $PSBoundParameters.Remove($psCmdlet.ParameterSetName) | Out-Null
        deploy-dappdb @PSBoundParameters
        Remove-Module "deploy-dappdb"
        break
    }
    default {Write-Error "Unable to determine ParameterSetName"; break}
}

