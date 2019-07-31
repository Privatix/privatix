<#
.SYNOPSIS
    Build Privatix installer on Windows
.DESCRIPTION
    Build Privatix installer on Windows

.PARAMETER branch
    Checkout existing git branch

.PARAMETER gitpull
    Pull from git

.PARAMETER wd
    working directory where source code is cloned/exist

.PARAMETER version
    Set version, if not overriden by git tag

.EXAMPLE
    build-dappinstaller

    Description
    -----------
    Build Dappinstaller.

.EXAMPLE
    build-dappinstaller -wd "c:\build\" -branch "develop" -gitpull -version "0.21.0"

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
        [ValidateScript({Test-Path $_ })]
        [string]$wd,
        [string]$version
    )

    $ErrorActionPreference = "Stop"
    if (($VerbosePreference -ne 'SilentlyContinue') -or ($PSBoundParameters.ContainsKey('Verbose')) ) {
        $goVerbose = ' -v '
        $goGenerateVerbose = ' -x '
    }
    
    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop -Verbose:$false
    Write-Verbose "Building dapp-installer"
    $gitUrl = "https://github.com/Privatix/dapp-installer.git"
    $PROJECT = "github.com\privatix\dapp-installer"

    # Check GOPATH is defined
    $gopath = $env:GOPATH
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env GOPATH"}
    if (!($gopath)) {throw "GOPATH is not defined"}
    
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
        Invoke-Scriptblock "go get $goVerbose -u github.com/rakyll/statik" -StderrPrefix ""
        Invoke-Scriptblock "go get $goVerbose -u github.com/josephspurrier/goversioninfo/cmd/goversioninfo" -StderrPrefix ""
        Invoke-Scriptblock "go get $goVerbose -u github.com/denisbrodbeck/machineid" -StderrPrefix ""
        Invoke-Scriptblock "go generate $goGenerateVerbose $PROJECT/..." -StderrPrefix ""
        Invoke-Scriptblock "go build -o $gopath\bin\dapp-installer.exe -ldflags `"-X main.Commit=$GIT_COMMIT -X main.Version=$GIT_RELEASE`"" -StderrPrefix ""
        Set-Location "$PROJECT_PATH\supervisor"
        Invoke-Scriptblock "go build -o $gopath\bin\dapp-supervisor.exe" -StderrPrefix ""
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
