<#
.SYNOPSIS
    Gathers various artifacts
.DESCRIPTION
    Gathers various artifacts

.PARAMETER wrkdir
    Directory where "app" and "deploy" folder will be created. This working directory will created.

.PARAMETER product
    Which Service plug-in to package. Can be "vpn" or "proxy"


.EXAMPLE
    new-package -wrkdir "c:\workdir" -staticArtefactsDir "c:\privatix\static_artifacts"

    Description
    -----------
    Package Privatix application.

.EXAMPLE
    new-package -wrkdir "c:\workdir" -staticArtefactsDir "c:\privatix\static_artifacts" -installer

    Description
    -----------
    Package Privatix application. Prepare for BitRock Installer build.

#>
function new-fastpackage {
    [cmdletbinding()]
    param(
        [ValidateNotNullorEmpty()]
        [ValidateScript( {Test-Path $_ -IsValid -PathType "Container"})]
        [string]$wrkdir,
        [ValidateSet('vpn', 'proxy')]
        [string]$product = 'vpn'
    )

    $ErrorActionPreference = "Stop"

    if ($PSBoundParameters.ContainsKey('Verbose')) {
        $global:VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
    }

    Write-Host "Working on packaging whole app..." -ForegroundColor Green
    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -Verbose:$false

    $rootAppPath = Join-Path $wrkdir "win-dapp-installer"
    
    # Product ID supposed to be unchangable for single product (e.g. VPN)
    if ($product -eq 'vpn') {$productID = '73e17130-2a1d-4f7d-97a8-93a9aaa6f10d'}
    if ($product -eq 'proxy') {$productID = '881da45b-ce8c-46bf-943d-730e9cee5740'}

    #region create working dir 
    if (!(Test-Path $wrkdir)) {New-Folder $wrkdir | Out-Null}
    if (!(Test-Path $rootAppPath)) {New-Folder $rootAppPath | Out-Null}
    #endregion

    # Check GOPATH is defined
    $gopath = $env:GOPATH
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env GOPATH"}
    if (!($gopath)) {throw "GOPATH is not defined"}

    #region define artefacts
    # artefacts
    # core installer
    $dappinstallerbin = (Get-Item "$gopath\bin\dapp-installer.exe").FullName
    $dappinstallerSupervisor = (Get-Item "$gopath\bin\dapp-supervisor.exe").FullName
    # common
    $dappctrlbin = (Get-Item "$gopath\bin\dappctrl.exe").FullName
    $updateConfigBinary = (Get-Item "$wrkdir\src\github.com\privatix\dapp-installer\tool\update-config\update-config.exe")

    # openvpn product
    if ($product -eq 'vpn') {
        $dappopenvpnbin = (Get-Item "$gopath\bin\dappvpn.exe").FullName
        $dappopenvpninst = (Get-Item "$gopath\bin\dappvpn-inst.exe").FullName
    }
    if ($product -eq 'proxy') {
        $dappproxybin = (Get-Item "$gopath\bin\dapp-proxy.exe").FullName
        $dappproxyinst = (Get-Item "$gopath\bin\dappproxy-inst.exe").FullName
    }
      
    
    #region core app

    #region dappctrl
    Copy-Item -Path $dappctrlbin -Destination "$rootAppPath\dappctrl.exe"
    #endregion
    
    #endregion

    #region product
    Copy-Item -Path $updateConfigBinary -Destination "$rootAppPath\update-config.exe" 

    #region binary
    if ($product -eq 'vpn') {
        Copy-Item -Path $dappopenvpnbin -Destination "$rootAppPath\dappvpn.exe"
        Copy-Item -Path $dappopenvpninst -Destination "$rootAppPath\inst.exe"
    }
    if ($product -eq 'proxy') {
        Copy-Item -Path $dappproxybin -Destination "$rootAppPath\dappproxy.exe"
        Copy-Item -Path $dappproxyinst -Destination "$rootAppPath\inst.exe"
    }
    #endregion

    #region dapp-installer artefact
    Copy-Item -Path $dappinstallerbin -Destination "$rootAppPath\dapp-installer.exe"
    Copy-Item -Path $dappinstallerSupervisor -Destination "$rootAppPath\dapp-supervisor.exe"
    #endregion

    #endregion
}