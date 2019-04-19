<#
.SYNOPSIS
    Build Privatix Proxy adapter and installer on Windows
.DESCRIPTION
    Build Privatix Proxy adapter and installer on Windows

.PARAMETER branch
    Checkout existing git branch

.PARAMETER gitpull
    Pull from git

.PARAMETER wd
    working directory where source code is cloned/exist

.PARAMETER version
    Set version, if not overriden by git tag

.EXAMPLE
    build-dappproxy

    Description
    -----------
    Build DappOpenVpn (includung installer).

.EXAMPLE
    build-dappproxy -wd "c:\build\" -branch "develop" -gitpull -version "0.21.0"

    Description
    -----------
    Checkout branch "develop". Pull from git. Run go dependecy. Build build-dappproxy adapter. Build build-dappproxy installer.
#>
Function build-dappproxy {
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
    Write-Verbose "Building dapp-proxy"
    $gitUrl = "https://github.com/Privatix/dapp-proxy.git"
    $PROJECT = "github.com\privatix\dapp-proxy"

    $gopath = $env:gopath
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env gopath"}
    if (!($gopath)) {throw "gopath is not defined"}

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
        Invoke-Scriptblock "go build -o $gopath\bin\dapp-proxy.exe -ldflags `"-X main.Commit=$GIT_COMMIT -X main.Version=$GIT_RELEASE`" -tags=notest .\plugin" -StderrPrefix ""
        Invoke-Scriptblock "go build -o $gopath\bin\dappproxy-inst.exe -ldflags `"-X main.Commit=$GIT_COMMIT -X main.Version=$GIT_RELEASE`" -tags=notest .\inst" -StderrPrefix ""
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
