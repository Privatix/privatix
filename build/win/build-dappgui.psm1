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

.EXAMPLE
   build-dappgui

   Description
   -----------
   Build dapp-gui and install to c:\privatix\dapp-gui.

.EXAMPLE
   build-dappgui -branch "develop" -gitpull -wd "$HOME\gui". Place shortcut is on desktop.

   Description
   -----------
   Checkout develop branch, git pull, build dapp-gui and install to $HOME\gui\dapp-gui. Place shortcut is on desktop.
#>
function build-dappgui {
    [cmdletbinding()]
    Param (
        [ValidatePattern("^(?!@$|build-|.*([.]\.|@\{|\\))[^\000-\037\177 ~^:?*[]+[^\000-\037\177 ~^:?*[]+(?<!\.lock|[.])$")]
        [string]$branch,
        [switch]$gitpull,
        [string]$wd = "c:\privatix\tmp",
        [switch]$package,
        [switch]$shortcut
    )
    Write-Verbose "Building dapp-gui"

    $gitUrl = "https://github.com/Privatix/dapp-gui.git"

    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop
    
    New-Folder $wd | Out-Null
    $artefactPath = Join-Path $wd "art"
    New-Folder $artefactPath | Out-Null
    $sourceCodePath = Join-Path $wd "dapp-gui"

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

    Copy-Gitrepo -path $sourceCodePath -gitUrl $gitUrl -ErrorAction Stop
        
    Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$sourceCodePath\.git --work-tree=$sourceCodePath status"
        
    #region Git checkout branch
    Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$sourceCodePath\.git --work-tree=$sourceCodePath fetch --all"
    if ($PSBoundParameters.ContainsKey('branch')) {
        Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$sourceCodePath\.git --work-tree=$sourceCodePath checkout $branch"
        $currentBranch = Invoke-Expression "git.exe --git-dir=$sourceCodePath\.git --work-tree=$sourceCodePath rev-parse --abbrev-ref HEAD"
        if ($branch -ne $currentBranch) {
            $currentBranch = Invoke-Expression "git.exe --git-dir=$sourceCodePath\.git --work-tree=$sourceCodePath rev-parse HEAD"    
            if ($branch -ne $currentBranch) {throw "failed to chekout $branch"}
        }
    }
    #endregion

    # Git pull
    if ($gitpull) {
        Write-Host "Pulling from Git..."
        Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$sourceCodePath\.git --work-tree=$sourceCodePath pull" -StderrPrefix "" -erraction "Continue"
    }
    else {Write-Warning "Skipping git pull"}
    #endregion
    
    
    $lastLocation = (Get-Location).Path
    Set-Location $sourceCodePath

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
    $settingsPath = "$sourceCodePath\build\settings.json"
    $SettingsJSON = Get-Content $settingsPath  | ConvertFrom-Json 
    $SettingsJSON.target = "win"
    $GIT_RELEASE = $(git.exe --git-dir=$sourceCodePath\.git --work-tree=$sourceCodePath tag -l --points-at HEAD)
    if ($GIT_RELEASE -notmatch "^([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$") {
        Write-Warning "Git release is not valid semver format"
    } else {$SettingsJSON.release = $GIT_RELEASE}
    $SettingsJSON | ConvertTo-Json | Out-File $settingsPath
    #endregion
    
    # npm package
    if ($package) {
        $lastLocation = (Get-Location).Path
        Set-Location $sourceCodePath
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
        $lnkInstalled = New-Shortcut -Path "$DesktopPath\Privatix.lnk" -TargetPath "C:\Windows\System32\cmd.exe" -Arguments $lnkcmd -WorkDir $sourceCodePath -Description "Privatix Dapp" -Icon "$sourceCodePath\assets\icon_64.png"
        
        if (-not $lnkInstalled) {Write-Error "Desktop shortcut creation failed"}
    }
    #endregion
    
}
