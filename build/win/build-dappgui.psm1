<#
.Synopsis
   Initialize GUI for Privatix app (dapp-gui)
.DESCRIPTION
   Initialize GUI for Privatix app (dapp-gui). Requires nodejs and npm.

.PARAMETER branch
    Checkout existing git branch

.PARAMETER gitpull
    Pull from git

.PARAMETER godep
    Use go dependency

.PARAMETER wd
    path where dapp-gui folder stored

.PARAMETER artefactPath
    path to packaged artefact. If not specified, no packaging is done.

.PARAMETER shortcut
    create shortcut (for testing purposes)

.PARAMETER version
    If version is specified and no git tag set, it will be define Dapp-GUI settings.json -> release.

.EXAMPLE
   build-dappgui

   Description
   -----------
   Build dapp-gui and install to <default build location>\dapp-gui.

.EXAMPLE
   build-dappgui -branch "develop" -gitpull -wd "$HOME\gui". -version "0.20.0"

   Description
   -----------
   Checkout develop branch, git pull, build dapp-gui and install. Set version of release, if no git tag exists.
#>
function build-dappgui {
    [cmdletbinding()]
    Param (
        [ValidatePattern("^(?!@$|build-|.*([.]\.|@\{|\\))[^\000-\037\177 ~^:?*[]+[^\000-\037\177 ~^:?*[]+(?<!\.lock|[.])$")]
        [string]$branch,
        [switch]$gitpull,
        [string]$wd = "c:\privatix\tmp",
        [switch]$package,
        [switch]$shortcut,
        [string]$version
    )
    
    $ErrorActionPreference = "Stop"

    Write-Verbose "Building dapp-gui"

    $gitUrl = "https://github.com/Privatix/dapp-gui.git"

    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop -Verbose:$false
    
    New-Folder $wd | Out-Null
    $artefactPath = Join-Path $wd "art"
    New-Folder $artefactPath | Out-Null
    $PROJECT_PATH = Join-Path $wd "dapp-gui"

    # check npm
    $ver = Find-App -appname "npm" -versioncmd "npm -v"

    # check nodejs 
    $ver = Find-App -appname "node"
    
    # check git
    $ver = Find-App -appname "git" -versioncmd "git.exe --version"
    
    #region install npm electron-packager
    try {
        $ver = Find-App -appname "electron-packager" -versioncmd "electron-packager --version"
    }
    catch {
        Write-Verbose "electron-packager not found. Trying to install..."
        Invoke-Scriptblock -ScriptBlock "npm install electron-packager -g" -StderrPrefix "" -ThrowOnError
    }
       
    try {
        $ver = Find-App -appname "electron-packager" -versioncmd "electron-packager --version"
    }
    catch {
        throw "Some failures accured during npm electron-packager install. Please, resolve."
    }    
    #endregion

    Copy-Gitrepo -path $PROJECT_PATH -gitUrl $gitUrl -ErrorAction Stop
        
    #region Git checkout branch
    if ($PSBoundParameters.ContainsKey('branch')) {
        checkout-gitbranch -PROJECT_PATH $PROJECT_PATH -branch $branch
    }
    #endregion

    # Git pull
    if ($gitpull) {
        Pull-Git -PROJECT_PATH $PROJECT_PATH
    }
    else {Write-Warning "Skipping git pull"}
    #endregion
    
    
    $lastLocation = (Get-Location).Path
    Set-Location $PROJECT_PATH

    $error.Clear()

    # npm install && build
    try {
        Invoke-Scriptblock -ScriptBlock "npm i" -StderrPrefix "" -ThrowOnError
        Invoke-Scriptblock -ScriptBlock "npm run build" -StderrPrefix "" -ThrowOnError
    }
    catch {Write-Error "Some failures accured during build"}
    finally {Set-Location $lastLocation}

    
    #region build status
    $errcnt = $Error.Count
    if ($errcnt -gt 0) {
        Write-Error "At least $errcnt occured, during build"
        
        $Error | ForEach-Object {Write-Host "Error number: $errcnt" -ForegroundColor Red; $errcnt--; $_.Exception}
    }
    #endregion

    #region set update fields
    
    $settingsPath = "$PROJECT_PATH\build\settings.json"
    $SettingsJSON = Get-Content $settingsPath  | ConvertFrom-Json 
    $SettingsJSON.target = "win"
    $GIT_RELEASE = $(git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH tag -l --points-at HEAD)

    if (-not $GIT_RELEASE -and $version) {
        $GIT_RELEASE = $version
    }
    if ($GIT_RELEASE) {$SettingsJSON.release = $GIT_RELEASE}
    
    $JSONstring = $SettingsJSON | ConvertTo-Json  
    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($settingsPath, $JSONstring, $Utf8NoBomEncoding)
    #endregion
    
    # npm package
    if ($package) {
        $lastLocation = (Get-Location).Path
        Set-Location $PROJECT_PATH
        try {
            Invoke-Scriptblock -ScriptBlock "npm run package-win" -StderrPrefix "" -ThrowOnError
        }
        catch {Write-Error "Some failures accured during packaging"}
        finally {Set-Location $lastLocation}
    }


    #region create shortcut
    if ($shortcut) {
        $DesktopPath = [Environment]::GetFolderPath("Desktop")
        
        if ($package) {$uiexec = Join-Path $artefactPath "dappctrlgui-win32-x64\dapp-gui.exe" -Resolve -ErrorAction Stop} else {$uiexec = '"npm" start'}
        
        $lnkcmd = '/c start "" /b "%GOPATH%\bin\dappctrl.exe" -config=%GOPATH%\src\github.com\privatix\dappctrl\dappctrl-dev.config.json & start "" /b ' + $uiexec
        $lnkInstalled = New-Shortcut -Path "$DesktopPath\Privatix.lnk" -TargetPath "C:\Windows\System32\cmd.exe" -Arguments $lnkcmd -WorkDir $PROJECT_PATH -Description "Privatix Dapp" -Icon "$PROJECT_PATH\assets\icon_64.png"
        
        if (-not $lnkInstalled) {Write-Error "Desktop shortcut creation failed"}
    }
    #endregion
    
}
