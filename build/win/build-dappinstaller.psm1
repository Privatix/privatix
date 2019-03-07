<#
.SYNOPSIS
    Build Privatix installer on Windows
.DESCRIPTION
    Build Privatix installer on Windows

.PARAMETER branch
    Checkout existing git branch

.PARAMETER gitpull
    Pull from git

.PARAMETER godep
    Use go dependency

.PARAMETER version
    Set version, if not overriden by git tag

.EXAMPLE
    build-dappinstaller

    Description
    -----------
    Build Dappinstaller.

.EXAMPLE
    build-dappinstaller -branch "develop" -godep -gitpull -version "0.21.0"

    Description
    -----------
    Checkout branch "develop". Pull from git. Run go dependecy. Build dapp-installer.
#>
Function build-dappinstaller {
    [cmdletbinding()]
    Param (
        [ValidatePattern("^(?!@$|build-|.*([.]\.|@\{|\\))[^\000-\037\177 ~^:?*[]+[^\000-\037\177 ~^:?*[]+(?<!\.lock|[.])$")]
        [string]$branch,        
        [switch]$gitpull,
        [switch]$godep,
        [string]$version
    )

    $ErrorActionPreference = "Stop"
    
    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop
    Write-Verbose "Building dapp-installer"
    $gitUrl = "https://github.com/Privatix/dapp-installer.git"
    $PROJECT = "github.com\privatix\dapp-installer"

    # Check GOPATH is defined
    $gopath = $env:GOPATH
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env GOPATH"}
    if (!($gopath)) {throw "GOPATH is not defined"}
    if (!(Test-Path $gopath)) {New-Folder -rootFolder $gopath}
    $PROJECT_PATH = "$gopath\src\$PROJECT"
    
    Invoke-GoCommonOperations -gopath $gopath -project $PROJECT -godep $godep -branch $branch -gitpull $gitpull -giturl $gitUrl -tomlTemplateFileName "Gopkg.toml.template"
    
    
    #region build
    $GIT_COMMIT = $(git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH rev-list -1 HEAD)
    $GIT_RELEASE = $(git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH tag -l --points-at HEAD)

    if ($version -notmatch "^([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$") {
        Write-Error "Version is not valid semver format"
    }
    if (($null -eq $GIT_RELEASE) -and ($null -ne $version)) {
        $GIT_RELEASE = $version
    }
    
    $lastLocation = (Get-Location).Path
    Set-Location $PROJECT_PATH

    $error.Clear()

    try {
        Invoke-Scriptblock "go get -d github.com/privatix/dapp-installer/..."
        Invoke-Scriptblock "go get -u github.com/rakyll/statik"
        Invoke-Scriptblock "go get -u github.com/josephspurrier/goversioninfo/cmd/goversioninfo"
        Invoke-Scriptblock "go generate $PROJECT/..."
        Invoke-Scriptblock "go build -o $GOPATH/bin/dapp-installer.exe -ldflags `"-X main.Commit=$GIT_COMMIT -X main.Version=$GIT_RELEASE`""
    }
    catch {Write-Error "Some failures accured during build"}
    finally {Set-Location $lastLocation}

    #endregion

    #region build status
    $errcnt = $Error.Count
    if ($errcnt -gt 0) {
        Write-Error "At least $errcnt occured, during build"
        
        $error | ForEach-Object {Write-Host "Error number: $errcnt" -ForegroundColor Red; $errcnt--; $_.Exception}
    }
    #endregion
    
}
