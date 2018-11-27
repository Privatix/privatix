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

.EXAMPLE
    new-package -wrkdir "c:\workdir" -staticArtefactsDir "c:\privatix\static_artifacts"

    Description
    -----------
    Package Privatix application.

#>
function new-package {
    [cmdletbinding()]
    param(
        [ValidateNotNullorEmpty()]
        [ValidateScript( {Test-Path $_ -IsValid -PathType "Container"})]
        [string]$wrkdir = "c:\privatix",
        [ValidateScript( {Test-Path $_ })]
        [string]$staticArtefactsDir

    )
 
    $ErrorActionPreference = "Stop"

    if ($PSBoundParameters.ContainsKey('Verbose')) {
        $global:VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
    }

    Write-Host "Working on packaging whole app..." -ForegroundColor Green
    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking


    $rootAppPath = Join-Path $wrkdir "app"
    $deployAppPath = Join-Path $wrkdir "deploy"
    $artefactDir = Join-Path $wrkdir "art"

    
    # Product ID supposed to be unchangable for single product (e.g. VPN)
    $productID = '73e17130-2a1d-4f7d-97a8-93a9aaa6f10d'

    #region create working dir 
    New-Folder $wrkdir | Out-Null
    New-Folder $deployAppPath | Out-Null
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
    # common
    $dappctrlbin = (Get-Item "$gopath\bin\dappctrl.exe").FullName
    $dappctrlconfig = (Get-Item "$gopath\src\github.com\privatix\dappctrl\dappctrl-dev.config.json").FullName
    $dappguiFolder = (Get-Item "$artefactDir\dappctrlgui-win32-x64").FullName
    $pgFolder = (Get-Item "$staticArtefactsDir\pgsql").FullName
    $utilFolder = (Get-Item "$staticArtefactsDir\util").FullName
    $torFolder = (Get-Item "$staticArtefactsDir\tor").FullName
    # openvpn product
    $dappopenvpnbin = (Get-Item "$gopath\bin\dappvpn.exe").FullName
    $dappopenvpninst = (Get-Item "$gopath\bin\inst.exe").FullName
    $templatesFolder = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\files\example").FullName
    $dappopenvpninstagentconfig = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\inst\install.agent.config.json").FullName
    $dappopenvpninstclientconfig = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\inst\install.client.config.json").FullName
    $agentAdapterInstallerConfig = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\inst\installer.agent.config.json").FullName
    $clientAdpaterInstallerConfig = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\inst\installer.client.config.json").FullName 
    
    $openvpnFolder = (Get-Item "$staticArtefactsDir\openvpn").FullName
    #endregion

    #region core app

    #region dappctrl
    Copy-Item -Path $dappctrlbin -Destination "$rootAppPath\dappctrl\dappctrl.exe"
    Copy-Item -Path $dappctrlconfig -Destination "$rootAppPath\dappctrl\dappctrl.config.json"
    #endregion

    #region dappgui
    Copy-Item -Path "$dappguiFolder\*" -Destination "$rootAppPath\dappgui" -Recurse -Force
    #endregion

    #region postgresql
    Copy-Item -Path "$pgFolder\*" -Destination "$rootAppPath\pgsql" -Recurse -Force
    #endregion

    #region util
    Copy-Item -Path "$utilFolder\*" -Destination "$rootAppPath\util" -Recurse -Force
    #endregion
    
    #region tor
    Copy-Item -Path "$torFolder\*" -Destination "$rootAppPath\tor" -Recurse -Force
    #endregion
    #endregion

    #region product

    #region binary
    Copy-Item -Path $dappopenvpnbin -Destination "$prodInstancePath\bin\dappvpn.exe"
    Copy-Item -Path $dappopenvpninst -Destination "$prodInstancePath\bin\inst.exe"
    Copy-Item -Path "$openvpnFolder" -Destination "$prodInstancePath\bin\openvpn" -Recurse -Force
    #endregion

    #region templates
    Copy-Item -Path "$templatesFolder\*" -Destination "$prodInstancePath\template" -Recurse -Force
    Rename-Item -Path "$prodInstancePath\template\dappvpn.agent.config.json" -NewName "$prodInstancePath\template\adapter.agent.config.json"
    Rename-Item -Path "$prodInstancePath\template\dappvpn.client.config.json" -NewName "$prodInstancePath\template\adapter.client.config.json"
    #endregion

    #region configs
    
    #Copy-Item -Path "$adapterconfig" -Destination "$prodInstancePath\config\adapter.config.json"
    Copy-Item -Path "$dappopenvpninstagentconfig" -Destination "$prodInstancePath\config\install.agent.config.json"
    Copy-Item -Path "$dappopenvpninstclientconfig" -Destination "$prodInstancePath\config\install.client.config.json"
    Copy-Item -Path "$agentAdapterInstallerConfig" -Destination "$prodInstancePath\config\installer.agent.config.json"
    Copy-Item -Path "$clientAdpaterInstallerConfig" -Destination "$prodInstancePath\config\installer.client.config.json"
    #endregion
    #endregion

    #region archive app
    Write-Verbose "Making archive for deploy..."
    add-type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($rootAppPath, "$deployAppPath\app.zip", 'NoCompression', $false)
    #endregion

    #region dapp-installer artefact
    Copy-Item -Path $dappinstallerbin -Destination "$deployAppPath\dapp-installer.exe"
    #endregion

    #region dev app installation scripts
    #region install shorcut
    $lnkcmd = '/c start "" /b .\dapp-installer.exe install --role agent --workdir .\agent --source .\app.zip --verbose'
    $lnkInstalled = New-Shortcut -Path "$deployAppPath\install_agent.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix Core install agent"
    if (-not $lnkInstalled) {Write-Error "Agent installer shortcut creation failed"}
    
    $lnkcmd = '/c start "" /b .\dapp-installer.exe install --role client --workdir .\client --source .\app.zip --verbose'
    $lnkInstalled = New-Shortcut -Path "$deployAppPath\install_client.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix Core install client"
    if (-not $lnkInstalled) {Write-Error "Client installer shortcut creation failed"}
    #endregion

    #region remove shortcut
    $lnkcmd = '/c start "" /b .\dapp-installer.exe remove --workdir .\agent --verbose'
    $lnkInstalled = New-Shortcut -Path "$deployAppPath\remove_agent.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix Core remove agent"
    if (-not $lnkInstalled) {Write-Error "Agent remover shortcut creation failed"}
    
    $lnkcmd = '/c start "" /b .\dapp-installer.exe remove --workdir .\client --verbose'
    $lnkInstalled = New-Shortcut -Path "$deployAppPath\remove_client.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix Core remove client"
    if (-not $lnkInstalled) {Write-Error "Client remover shortcut creation failed"}
    
    #endregion
    #endregion
}