<#
.SYNOPSIS
    Build Privatix controller (dappctrl) on Windows
.DESCRIPTION
    Build Privatix controller (dappctrl) on Windows

.PARAMETER branch
    Checkout existing git branch

.PARAMETER gitpull
    Pull from git

.PARAMETER wd
    working directory where source code is cloned/exist

.PARAMETER version
    Set version, if not overriden by git tag

.EXAMPLE
    build-dappctrl

    Description
    -----------
    Build dappctrl.

.EXAMPLE
    build-dappctrl -wd "c:\build\" -branch "develop" -gitpull -version "0.21.0"

    Description
    -----------
    Checkout branch "develop". Pull from git. Run go dependecy. Build dappctrl.
#>
Function build-dappctrl {
    [cmdletbinding()]
    Param (
        [ValidatePattern("^(?!@$|build-|.*([.]\.|@\{|\\))[^\000-\037\177 ~^:?*[]+[^\000-\037\177 ~^:?*[]+(?<!\.lock|[.])$")]
        [string]$branch,        
        [switch]$gitpull,
        [ValidateScript({Test-Path $_ })]
        [string]$wd,
        [string]$version
    )
    
    $ErrorActionPreference = "Stop"
    
    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop
    Write-Verbose "Building dappctrl"
    $gitUrl = "https://github.com/Privatix/dappctrl.git"
    $PROJECT = "github.com\privatix\dappctrl"
    
    $PROJECT_PATH = "$wd\src\$PROJECT"

    Invoke-GoCommonOperations -PROJECT_PATH $PROJECT_PATH -branch $branch -gitpull $gitpull -giturl $gitUrl
    
    #region build
    $GIT_COMMIT = $(git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH rev-list -1 HEAD)
    $GIT_RELEASE = $(git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH tag -l --points-at HEAD)
    
    if (-not $GIT_RELEASE -and $version) {
        $GIT_RELEASE = $version
    }

    $lastLocation = (Get-Location).Path
    Set-Location $PROJECT_PATH

    $error.Clear()

    try {
        Invoke-Scriptblock "go get $goVerbose -u gopkg.in/reform.v1/reform" -StderrPrefix ""
        Invoke-Scriptblock "go get $goVerbose -u github.com/rakyll/statik" -StderrPrefix ""
        Invoke-Scriptblock "go get $goVerbose -u github.com/pressly/goose/cmd/goose" -StderrPrefix ""
        Invoke-Scriptblock "go get $goVerbose github.com/ethereum/go-ethereum/cmd/abigen" -StderrPrefix ""
        Invoke-Scriptblock "go generate $goVerbose -x $PROJECT/..." -StderrPrefix ""
        Invoke-Scriptblock "go install $goVerbose -ldflags `"-X main.Commit=$GIT_COMMIT -X main.Version=$GIT_RELEASE`" -tags=notest $PROJECT" -StderrPrefix ""
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
