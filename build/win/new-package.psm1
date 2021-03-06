<#
.SYNOPSIS
    Prepare application for distribution
.DESCRIPTION
    Prepare application for distribution. Creates folder structre in "app". This folder
    contains all artifacts.
    Creates "deploy" folder, which mimics application ready for distribution. 
    NOTE: This cmdlet expects various components to be ready in specific locations and with specific names.

.PARAMETER wrkdir
    Directory where "app" and "deploy" folder will be created. This working directory will created.

.PARAMETER staticArtefactsDir
    Folder, where static artifacts exists, such as postgresql, tor, visual studio redistributable.

.PARAMETER installer
    Prepare artefacts for BitRock installer

.PARAMETER privatixbranch
    Git branch to checkout for privatix repo. If not specified "develop" branch will be used.

.PARAMETER gitpull
    Make git pull before checkout for privatix repo.

.PARAMETER dappctrlConf
    Specifes filename of dappctrl config. By default "dappctrl-dev.config.json" is used
    
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
function new-package {
    [cmdletbinding()]
    param(
        [ValidateNotNullorEmpty()]
        [ValidateScript( {Test-Path $_ -IsValid -PathType "Container"})]
        [string]$wrkdir,
        [ValidateScript( {Test-Path $_ })]
        [string]$staticArtefactsDir,
        [switch]$installer,
        [string]$privatixbranch = "develop",
        [switch]$gitpull,
        [string]$dappctrlConf = "dappctrl-dev.config.json",
        [ValidateSet('vpn', 'proxy')]
        [string]$product = 'vpn'

    )

    # Check if dappctrl config defined
    if ([string]::IsNullOrEmpty($dappctrlConf)) {
        $dappctrlConf = "dappctrl-dev.config.json"
        Write-Verbose "Config for dappctrl not set explicitly. Fallback to `"dappctrl-dev.config.json`""
    }

    $ErrorActionPreference = "Stop"

    if ($PSBoundParameters.ContainsKey('Verbose')) {
        $global:VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
    }

    Write-Host "Working on packaging whole app..." -ForegroundColor Green
    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -Verbose:$false


    $rootAppPath = Join-Path $wrkdir "app"
    $deployAppPath = Join-Path $wrkdir "win-dapp-installer"
    $bitrockProjectDir = Join-Path $wrkdir "project"
    $privatixSourceCodePath = Join-Path $wrkdir "src\github.com\privatix\privatix"

    #region privatix repo
    $gitUrl = "https://github.com/Privatix/privatix.git"
    Copy-Gitrepo -path $privatixSourceCodePath -gitUrl $gitUrl -ErrorAction Stop

        

    #region Git checkout branch
    if ($PSBoundParameters.ContainsKey('branch')) {
        checkout-gitbranch -PROJECT_PATH $privatixSourceCodePath -branch $privatixbranch
    }
    #endregion
    #region Git pull
    if ($PSBoundParameters.ContainsKey('gitpull')) {
        Pull-Git -PROJECT_PATH $privatixSourceCodePath
    }
    #endregion
    
    # Product ID supposed to be unchangable for single product (e.g. VPN)
    if ($product -eq 'vpn') {$productID = '73e17130-2a1d-4f7d-97a8-93a9aaa6f10d'}
    if ($product -eq 'proxy') {$productID = '881da45b-ce8c-46bf-943d-730e9cee5740'}

    #region create working dir 
    if (!(Test-Path $wrkdir)) {New-Folder $wrkdir | Out-Null}
    if (!(Test-Path $deployAppPath)) {New-Folder $deployAppPath | Out-Null}
    #endregion

    #region create core app folder structure
    ##################
    # privatix
    ## dappctrl
    ## dappgui
    ## pgsql
    ### data
    #util
    #log
    #product

    #core app hierarchy
    New-Folder $rootAppPath | Out-Null
    New-Folder $rootAppPath "dappctrl" | Out-Null
    New-Folder $rootAppPath "dappgui" | Out-Null
    New-Folder $rootAppPath "pgsql" | Out-Null
    New-Folder $rootAppPath "util" | Out-Null
    New-Folder $rootAppPath "log" | Out-Null
    New-Folder $rootAppPath "tor" | Out-Null
    #TODO(sofabeat): fix when unpacked, seen as empty file, thus using dumb file
    Get-Date | Out-File -FilePath "$rootAppPath\log\date.txt"
    $rootProductPath = New-Folder $rootAppPath "product"
    #endregion

    #region create product instance folder structure
    ##product hierarchy 
    ### bin
    ### config
    ### data
    ### log
    ### template
    $prodInstancePath = New-Folder $rootProductPath $productID
    New-Folder $prodInstancePath "bin" | Out-Null
    New-Folder $prodInstancePath "config" | Out-Null
    New-Folder $prodInstancePath "data" | Out-Null
    Get-Date | Out-File -FilePath "$prodInstancePath\data\date.txt"
    New-Folder $prodInstancePath "log" | Out-Null
    Get-Date | Out-File -FilePath "$prodInstancePath\log\date.txt"
    New-Folder $prodInstancePath "template" | Out-Null
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
    $dappctrlconfig = (Get-Item "$wrkdir\src\github.com\privatix\dappctrl\$dappctrlConf").FullName
    $dappctrlFWruleScript = (Get-Item "$wrkdir\src\github.com\privatix\dappctrl\scripts\win\set-ctrlfirewall.ps1").FullName
    if ($installer) {
        $dappguiFolder = (Get-Item "$wrkdir\dapp-gui\release-builds\dapp-gui-win32-x64").FullName
    } else {$dappguiFolder = (Get-Item "$wrkdir\dapp-gui").FullName}

    $pgFolder = (Get-Item "$staticArtefactsDir\pgsql").FullName
    $utilFolder = (Get-Item "$staticArtefactsDir\util").FullName
    $torFolder = (Get-Item "$staticArtefactsDir\tor").FullName
    $dumpScript = (Get-Item "$privatixSourceCodePath\tools\dump_win\new-dump.ps1").FullName
    $psRunnerBinary = (Get-Item "$privatixSourceCodePath\tools\dump_win\ps-runner.exe").FullName
    $updateConfigBinary = (Get-Item "$wrkdir\src\github.com\privatix\dapp-installer\tool\update-config\update-config.exe")

    # openvpn product
    if ($product -eq 'vpn') {
        $dappopenvpnbin = (Get-Item "$gopath\bin\dappvpn.exe").FullName
        $dappopenvpninst = (Get-Item "$gopath\bin\dappvpn-inst.exe").FullName
        $dappvpntemplatesFolder = (Get-Item "$wrkdir\src\github.com\privatix\dapp-openvpn\files\example").FullName
        $dappopenvpninstagentconfig = (Get-Item "$wrkdir\src\github.com\privatix\dapp-openvpn\inst\install.agent.win.config.json").FullName
        $dappopenvpninstclientconfig = (Get-Item "$wrkdir\src\github.com\privatix\dapp-openvpn\inst\install.client.win.config.json").FullName
        $dappopenvpnagentAdapterInstallerConfig = (Get-Item "$wrkdir\src\github.com\privatix\dapp-openvpn\inst\installer.agent.config.json").FullName
        $dappopenvpnclientAdpaterInstallerConfig = (Get-Item "$wrkdir\src\github.com\privatix\dapp-openvpn\inst\installer.client.config.json").FullName 
        $dappopenvpnFWruleScript = (Get-Item "$wrkdir\src\github.com\privatix\dapp-openvpn\scripts\win\set-vpnfirewall.ps1").FullName
        $dappopenvpnSetNAT = (Get-Item "$wrkdir\src\github.com\privatix\dapp-openvpn\scripts\win\set-nat.ps1").FullName
        $dappopenvpnScheduleTaskScript = (Get-Item "$wrkdir\src\github.com\privatix\dapp-openvpn\scripts\win\new-startupTask.ps1").FullName
        $dappopenvpnReenableNat = (Get-Item "$wrkdir\src\github.com\privatix\dapp-openvpn\scripts\win\reenable-nat.ps1").FullName
    }
    if ($product -eq 'proxy') {
        $dappproxybin = (Get-Item "$gopath\bin\dapp-proxy.exe").FullName
        $dappproxyinst = (Get-Item "$gopath\bin\dappproxy-inst.exe").FullName
        $dappproxytemplatesFolder = (Get-Item "$wrkdir\src\github.com\privatix\dapp-proxy\product\template").FullName
        $dappproxybinFolder = (Get-Item "$wrkdir\src\github.com\privatix\dapp-proxy\product\bin").FullName
        $dappproxyconfigFolder = (Get-Item "$wrkdir\src\github.com\privatix\dapp-proxy\product\config").FullName


        #$dappproxyFWruleScript = (Get-Item "$wrkdir\src\github.com\privatix\dapp-proxy\scripts\win\set-vpnfirewall.ps1").FullName
        #$dappproxySetNAT = (Get-Item "$wrkdir\src\github.com\privatix\dapp-proxy\scripts\win\set-nat.ps1").FullName
        #$dappproxyScheduleTaskScript = (Get-Item "$wrkdir\src\github.com\privatix\dapp-proxy\scripts\win\new-startupTask.ps1").FullName
        #$dappproxyReenableNat = (Get-Item "$wrkdir\src\github.com\privatix\dapp-proxy\scripts\win\reenable-nat.ps1").FullName
    }
      
    $openvpnFolder = (Get-Item "$staticArtefactsDir\openvpn").FullName
    $proxyFolder = (Get-Item "$staticArtefactsDir\v2ray").FullName
    # bitrock installer
    $bitrockProjectDirSource = (Get-Item "$wrkdir\src\github.com\privatix\dapp-installer\installbuilder\project").FullName
    #endregion

    #region core app

    #region dappctrl
    Copy-Item -Path $dappctrlbin -Destination "$rootAppPath\dappctrl\dappctrl.exe"
    Copy-Item -Path $dappctrlconfig -Destination "$rootAppPath\dappctrl\dappctrl.config.json"
    Copy-Item -Path $dappctrlFWruleScript -Destination "$rootAppPath\dappctrl\set-ctrlfirewall.ps1"
    #endregion

    #region dappgui
    Copy-Item -Path "$dappguiFolder\*" -Destination "$rootAppPath\dappgui" -Recurse -Force
    #endregion

    #region postgresql
    Copy-Item -Path "$pgFolder\*" -Destination "$rootAppPath\pgsql" -Recurse -Force
    #endregion

    #region util
    Copy-Item -Path "$utilFolder\*" -Destination "$rootAppPath\util" -Recurse -Force
    New-Folder "$rootAppPath\util" "dump" | Out-Null
    Copy-Item -Path $dumpScript -Destination "$rootAppPath\util\dump\new-dump.ps1"
    Copy-Item -Path $psRunnerBinary -Destination "$rootAppPath\util\dump\ps-runner.exe"
    #endregion
    
    #region tor
    Copy-Item -Path "$torFolder\*" -Destination "$rootAppPath\tor" -Recurse -Force
    #endregion
    #endregion

    #region product
    Copy-Item -Path $updateConfigBinary -Destination "$prodInstancePath\bin\update-config.exe" 

    #region binary
    if ($product -eq 'vpn') {
        Copy-Item -Path $dappopenvpnbin -Destination "$prodInstancePath\bin\dappvpn.exe"
        Copy-Item -Path $dappopenvpninst -Destination "$prodInstancePath\bin\inst.exe"
        Copy-Item -Path $dappopenvpnFWruleScript -Destination "$prodInstancePath\bin\set-vpnfirewall.ps1"
        Copy-Item -Path $dappopenvpnSetNAT -Destination "$prodInstancePath\bin\set-nat.ps1"
        Copy-Item -Path $dappopenvpnScheduleTaskScript -Destination "$prodInstancePath\bin\new-startupTask.ps1"
        Copy-Item -Path $dappopenvpnReenableNat -Destination "$prodInstancePath\bin\reenable-nat.ps1"
        Copy-Item -Path $openvpnFolder -Destination "$prodInstancePath\bin\openvpn" -Recurse -Force
    }
    if ($product -eq 'proxy') {
        Copy-Item -Path $dappproxybin -Destination "$prodInstancePath\bin\dappproxy.exe"
        Copy-Item -Path $dappproxyinst -Destination "$prodInstancePath\bin\inst.exe"
        
        #Copy-Item -Path $dappproxyFWruleScript -Destination "$prodInstancePath\bin\set-vpnfirewall.ps1"
        #Copy-Item -Path $dappproxySetNAT -Destination "$prodInstancePath\bin\set-nat.ps1"
        #Copy-Item -Path $dappproxyScheduleTaskScript -Destination "$prodInstancePath\bin\new-startupTask.ps1"
        #Copy-Item -Path $dappproxyReenableNat -Destination "$prodInstancePath\bin\reenable-nat.ps1"
        Copy-Item -Path $proxyFolder -Destination "$prodInstancePath\bin\v2ray" -Recurse -Force
    }
    #endregion

    #region templates
    if ($product -eq 'vpn') {
        Copy-Item -Path "$dappvpntemplatesFolder\*" -Destination "$prodInstancePath\template" -Recurse -Force
        Rename-Item -Path "$prodInstancePath\template\dappvpn.agent.config.json" -NewName "$prodInstancePath\template\adapter.agent.config.json"
        Rename-Item -Path "$prodInstancePath\template\dappvpn.client.config.json" -NewName "$prodInstancePath\template\adapter.client.config.json"
    }
    if ($product -eq 'proxy') {
        Copy-Item -Path "$dappproxytemplatesFolder\*" -Destination "$prodInstancePath\template" -Recurse -Force
        Copy-Item -Path "$dappproxybinFolder\*" -Destination "$prodInstancePath\bin" -Recurse -Force
    }
    #endregion

    #region configs
    
    if ($product -eq 'vpn') {
        Copy-Item -Path "$dappopenvpninstagentconfig" -Destination "$prodInstancePath\config\install.agent.config.json"
        Copy-Item -Path "$dappopenvpninstclientconfig" -Destination "$prodInstancePath\config\install.client.config.json"
        Copy-Item -Path "$dappopenvpnagentAdapterInstallerConfig" -Destination "$prodInstancePath\config\installer.agent.config.json"
        Copy-Item -Path "$dappopenvpnclientAdpaterInstallerConfig" -Destination "$prodInstancePath\config\installer.client.config.json"
    }
    if ($product -eq 'proxy') {
        Copy-Item -Path "$dappproxyconfigFolder\*" -Destination "$prodInstancePath\config" -Recurse -Force
        
    }
    #endregion
    #endregion

    #region bitrock project
    Copy-Item -Path "$bitrockProjectDirSource" -Destination $bitrockProjectDir -Recurse -Force
    #endregion

    #region archive app
    if ($installer) {
        Write-Verbose "Making archive for deploy..."
        add-type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::CreateFromDirectory($rootAppPath, "$deployAppPath\app.zip", 'Optimal', $false)
    }
    #endregion

    #region dapp-installer artefact
    Copy-Item -Path $dappinstallerbin -Destination "$deployAppPath\dapp-installer.exe"
    Copy-Item -Path $dappinstallerSupervisor -Destination "$deployAppPath\dapp-supervisor.exe"
    #endregion

    #endregion
}