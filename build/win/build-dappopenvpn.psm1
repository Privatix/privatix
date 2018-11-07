<#
.SYNOPSIS
    Build Privatix OpenVPN adapter and installer on Windows
.DESCRIPTION
    Build Privatix OpenVPN adapter and installer on Windows

.PARAMETER branch
    Checkout existing git branch

.PARAMETER gitpull
    Pull from git

.PARAMETER godep
    Use go dependency

.EXAMPLE
    build-dappopenvpn

    Description
    -----------
    Build DappOpenVpn (includung installer).

.EXAMPLE
    build-dappopenvpn -branch "develop" -godep -gitpull

    Description
    -----------
    Checkout branch "develop". Pull from git. Run go dependecy. Build dapp-openvpn adapter. Build dapp-openvpn installer.
#>
Function build-dappopenvpn {
    [cmdletbinding()]
    Param (
        [parameter()]
        [ValidatePattern("^(?!@$|build-|.*([.]\.|@\{|\\))[^\000-\037\177 ~^:?*[]+[^\000-\037\177 ~^:?*[]+(?<!\.lock|[.])$")]
        [string]$branch,        
        [parameter()]
        [switch]$gitpull,
        [parameter()]
        [switch]$godep
    )
    
    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop
    Write-Verbose "Building dapp-openvpn"
    $gitUrl = "https://github.com/Privatix/dapp-openvpn.git"
    $PROJECT = "github.com\privatix\dapp-openvpn"

    # Check GOPATH is defined
    $gopath = $env:GOPATH
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env GOPATH"}
    if (!($gopath)) {throw "GOPATH is not defined"}    
    if (!(Test-Path $gopath)) {throw "GOPATH $gopath do not exists"}
    $PROJECT_PATH = "$gopath\src\$PROJECT"

    Invoke-GoCommonOperations -gopath $gopath -project $PROJECT -godep $godep -branch $branch -gitpull $gitpull -giturl $gitUrl

    #region build
    $GIT_COMMIT = $(git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH rev-list -1 HEAD)
    $GIT_RELEASE = $(git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH tag -l --points-at HEAD)

    if ($GIT_RELEASE -notmatch "^([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)\.([0-9]|[1-9][0-9]*)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$") {
        Write-Warning "Git release is not valid semver format"
    }
    
    $lastLocation = (Get-Location).Path
    Set-Location $PROJECT_PATH

    $error.Clear()

    try {
        Invoke-Scriptblock "go generate $PROJECT/..."
        Invoke-Scriptblock "go build -o $GOPATH/bin/dappvpn.exe -ldflags `"-X main.Commit=$GIT_COMMIT -X main.Version=$GIT_RELEASE`" -tags=notest ${PROJECT}\adapter"
        Invoke-Scriptblock "go build -o $GOPATH/bin/installer.exe -ldflags `"-X main.Commit=$GIT_COMMIT -X main.Version=$GIT_RELEASE`" -tags=notest ${PROJECT}\installer"
        Invoke-Scriptblock "go build -o $GOPATH/bin/inst.exe -ldflags `"-X main.Commit=$GIT_COMMIT -X main.Version=$GIT_RELEASE`" -tags=notest ${PROJECT}\inst"
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
