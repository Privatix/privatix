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
    # core installer
    $agentAdpaterInstallerConfig = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\inst\agent.installer.config.json").FullName
    $clientAdpaterInstallerConfig = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\inst\client.installer.config.json").FullName
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
    $dappopenvpninstaller = (Get-Item "$gopath\bin\installer.exe").FullName
    $dappopenvpninstallerconfig = (Get-Item "$gopath\src\github.com\privatix\dapp-installer\dapp-installer.config.json").FullName
    $templatesFolder = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\files\example").FullName
    $adapterconfig = (Get-Item "$gopath\src\github.com\privatix\dapp-openvpn\statik\package\config\adapter.config.json").FullName
    
    $openvpnFolder = (Get-Item "$staticArtefactsDir\openvpn").FullName
    

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
    #Copy-Item -Path "$adapterconfig" -Destination "$prodInstancePath\config\dappvpn.config.json"
    #endregion

    #region installer config
    Copy-Item -Path "$agentAdpaterInstallerConfig" -Destination "$prodInstancePath\config\agent.installer.config.json"
    Copy-Item -Path "$clientAdpaterInstallerConfig" -Destination "$prodInstancePath\config\client.installer.config.json"
    
    #endregion

    #endregion

    #region create deploy app

    #endregion
    #region dapp-installer artefact
    Copy-Item -Path $dappinstallerbin -Destination "$deployAppPath\dapp-installer.exe"
    Copy-Item -Path $dappopenvpninstallerconfig -Destination "$deployAppPath\dapp-installer.config.json"
    #endregion

    #region dapp-openvpn install shorcut
    $scriptContent = @'
    param(
        [Parameter(Mandatory=$true, ParameterSetName = "agent", HelpMessage = "install as agent")]
        [switch]$agent,
        [Parameter(Mandatory=$true, ParameterSetName = "client", HelpMessage = "install as client")]
        [switch]$client
    )
    # Install product into dappctrl database and update adapter config file with authentication credentials
    $rootAppPath = (get-item $PSScriptRoot).Parent.Parent.Parent.FullName
    $prodInstancePath = (get-item $PSScriptRoot).Parent.FullName
    Write-Host "Parse dappctrl config DB section"
    $dappctrlconf = "$rootAppPath\dappctrl\dappctrl.config.json"
    Write-Host "Parsing config file: $dappctrlconf"
    $DBconf = (Get-Content $dappctrlconf -ErrorAction Stop| ConvertFrom-Json).DB.conn
    $connstr = "host=$($DBconf.host) dbname=$($DBconf.dbname) user=$($DBconf.user) port=$($DBconf.port)"
    if ($($DBconf.password)) {$connstr += " password=$($DBconf.password)"}
    $connstr += " sslmode=disable"
    Write-Host "Connection string is: $connstr"
    $expression = ".\installer.exe --connstr  `"" + $connstr + '" --rootdir="..\template" -setauth'
    Write-Host "Executing command: $expression"
    Invoke-Expression $expression -ErrorAction SilentlyContinue
    if ($agent.IsPresent) {Copy-Item -Path "$prodInstancePath\template\dappvpn.agent.config.json" -Destination "$prodInstancePath\config\dappvpn.config.json" -Force }
    if ($client.IsPresent) {Copy-Item -Path "$prodInstancePath\template\dappvpn.client.config.json" -Destination "$prodInstancePath\config\dappvpn.config.json" -Force}
'@
    $scriptContent | Out-File -FilePath "$prodInstancePath\bin\install-product.ps1"
    #endregion

    #region dapp-openvpn inst shortcut
    $lnkcmd = '/c start "" /b .\inst.exe install --config "..\config\installer.config.json"'
    $lnkInstalled = New-Shortcut -Path "$prodInstancePath\bin\install_adapter.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix adapter install"
    if (-not $lnkInstalled) {Write-Error "Adapter install shortcut creation failed"}

    $lnkcmd = '/c start "" /b .\inst.exe remove"'
    $lnkInstalled = New-Shortcut -Path "$prodInstancePath\bin\remove_adapter.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix adapter remove"
    if (-not $lnkInstalled) {Write-Error "Adapter install shortcut creation failed"}
    #endregion
    
    #region archive app
    Write-Verbose "Making archive for deploy..."
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
    
    $lnkcmd = '/c start "" /b .\dapp-installer.exe remove --workdir .\client'
    $lnkInstalled = New-Shortcut -Path "$deployAppPath\remove_client.lnk" -TargetPath "%ComSpec%" -Arguments $lnkcmd -WorkDir "%~dp0" -Description "Privatix Core remove client"
    if (-not $lnkInstalled) {Write-Error "Client remover shortcut creation failed"}
    
    #endregion
    #endregion
    #endregion
}