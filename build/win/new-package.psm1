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
    #end region

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
    #New-Folder $pgsqlPath "data" | Out-Null
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

    # Check GOPATH is defined
    $gopath = $env:GOPATH
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env GOPATH"}
    if (!($gopath)) {throw "GOPATH is not defined"}

    # artefacts
    $dappctrlbin = (Get-Item "$gopath\bin\dappctrl.exe").FullName
    $dappctrlconfig = (Get-Item "$gopath\src\github.com\privatix\dappctrl\dappctrl-dev.config.json").FullName
    $dappguiFolder = (Get-Item "$artefactDir\dappctrlgui-win32-x64").FullName
    $pgFolder = (Get-Item "$staticArtefactsDir\pgsql").FullName
    $utilFolder = (Get-Item "$staticArtefactsDir\util").FullName
    $dappopenvpnbin = (Get-Item "$gopath\bin\dappvpn.exe").FullName
    $dappopenvpninst = (Get-Item "$gopath\bin\inst.exe").FullName
    $dappopenvpninstaller = (Get-Item "$gopath\bin\installer.exe").FullName
    $dappopenvpninstallerconfig = (Get-Item "$gopath\src\github.com\privatix\dapp-installer\dapp-installer.config.json").FullName
    $templatesFolder = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\statik\package\template").FullName
    $adapterconfig = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\statik\package\config\adapter.config.json").FullName
    $adpaterinstallerconfig = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\inst\installer.config.json").FullName
    $dappinstallerbin = (Get-Item "$gopath\bin\dapp-installer.exe").FullName
    $openvpnFolder = (Get-Item "$staticArtefactsDir\openvpn").FullName
    $torFolder = (Get-Item "$staticArtefactsDir\tor").FullName

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


    #region adapter

    #region binary
    Copy-Item -Path $dappopenvpnbin -Destination "$prodInstancePath\bin\dappvpn.exe"
    Copy-Item -Path $dappopenvpninst -Destination "$prodInstancePath\bin\inst.exe"
    Copy-Item -Path $dappopenvpninstaller -Destination "$prodInstancePath\bin\installer.exe"
    Copy-Item -Path "$openvpnFolder" -Destination "$prodInstancePath\bin\openvpn" -Recurse -Force
    #endregion

    #region templates
    Copy-Item -Path "$templatesFolder\*" -Destination "$prodInstancePath\template" -Recurse -Force
    #endregion

    #region adapter config
    Copy-Item -Path "$adapterconfig" -Destination "$prodInstancePath\config\dappvpn.config.json"
    #endregion

    #region installer config
    Copy-Item -Path "$adpaterinstallerconfig" -Destination "$prodInstancePath\config\installer.config.json"
    #endregion

    #endregion

    #region create deploy app

    #endregion
    #region dapp-installer artefact
    Copy-Item -Path $dappinstallerbin -Destination "$deployAppPath\dapp-installer.exe"
    Copy-Item -Path $dappopenvpninstallerconfig -Destination "$deployAppPath\dapp-installer.config.json"
    #endregion

    #region archive app
    add-type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($rootAppPath, "$deployAppPath\app.zip", 'NoCompression', $false)
    #endregion

    #region shortcut
    #region install shorcut
    $lnkcmd = '/c start "" /b .\dapp-installer.exe install --role agent --workdir .\agent --source .\app.zip'
    $lnkInstalled = New-Shortcut -Path "$deployAppPath\install_agent.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix Core install agent"
    if (-not $lnkInstalled) {Write-Error "Agent installer shortcut creation failed"}
    
    $lnkcmd = '/c start "" /b .\dapp-installer.exe install --role client --workdir .\client --source .\app.zip'
    $lnkInstalled = New-Shortcut -Path "$deployAppPath\install_client.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix Core install client"
    if (-not $lnkInstalled) {Write-Error "Client installer shortcut creation failed"}
    #endregion

    #region remove shortcut
    $lnkcmd = '/c start "" /b .\dapp-installer.exe remove --workdir .\agent'
    $lnkInstalled = New-Shortcut -Path "$deployAppPath\remove_agent.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix Core remove agent"
    if (-not $lnkInstalled) {Write-Error "Agent remover shortcut creation failed"}
    
    $lnkcmd = '/c start "" /b .\dapp-installer.exe install --workdir .\client'
    $lnkInstalled = New-Shortcut -Path "$deployAppPath\remove_client.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix Core remove client"
    if (-not $lnkInstalled) {Write-Error "Client remover shortcut creation failed"}
    
    #endregion
    #endregion
    #endregion
}