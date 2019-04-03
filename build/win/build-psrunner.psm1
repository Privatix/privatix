<#
.SYNOPSIS
    Build tool psrunner on Windows
.DESCRIPTION
    Build tool psrunner on Windows. Tool helps to execute underlying powershell script.

.PARAMETER branch
    Checkout existing git branch

.PARAMETER gitpull
    Pull from git

PARAMETER wd
    working directory where source code is cloned/exist

.EXAMPLE
    build-psrunner

    Description
    -----------
    Build psrunner

.EXAMPLE
    build-psrunner -branch "develop" -godep -gitpull

    Description
    -----------
    Checkout branch "develop". Pull from git. Run go dependecy. Build psrunner.
#>
Function build-psrunner {
    [cmdletbinding()]
    Param (
        [ValidatePattern("^(?!@$|build-|.*([.]\.|@\{|\\))[^\000-\037\177 ~^:?*[]+[^\000-\037\177 ~^:?*[]+(?<!\.lock|[.])$")]
        [string]$branch,        
        [switch]$gitpull,
        [ValidateScript({Test-Path $_ })]
        [string]$wd
    )
    
    $ErrorActionPreference = "Stop"
    if (($VerbosePreference -ne 'SilentlyContinue') -or ($PSBoundParameters.ContainsKey('Verbose')) ) {
        $goVerbose = ' -v '
        $goGenerateVerbose = ' -x '
    }

    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop
    Write-Verbose "Building ps-runner"
    $gitUrl = "https://github.com/Privatix/dapp-installer.git"
    $PROJECT = "github.com\privatix\dapp-installer"

    $gopath = $env:gopath
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env gopath"}
    if (!($gopath)) {throw "gopath is not defined"}
    $PROJECT_PATH = "$wd\src\$PROJECT"
    $toolPath = "tool\ps-runner"

    Invoke-GoCommonOperations -PROJECT_PATH $PROJECT_PATH -branch $branch -gitpull $gitpull -giturl $gitUrl
    
    #region build

    $lastLocation = (Get-Location).Path
    Set-Location "$PROJECT_PATH\$toolPath"

    $error.Clear()

    try {
        Invoke-Scriptblock "go get $goVerbose -u github.com/josephspurrier/goversioninfo/cmd/goversioninfo" -StderrPrefix ""
        Invoke-Scriptblock "go generate $goGenerateVerbose $PROJECT/$toolPath/..." -StderrPrefix ""
        Invoke-Scriptblock "go build -o $gopath\bin\ps-runner.exe" -StderrPrefix ""
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
