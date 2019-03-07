<#
.SYNOPSIS
    Build tool psrunner on Windows
.DESCRIPTION
    Build tool psrunner on Windows. Tool helps to execute underlying powershell script.

.PARAMETER branch
    Checkout existing git branch

.PARAMETER gitpull
    Pull from git

.PARAMETER godep
    Use go dependency

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
        [switch]$godep
    )
    
    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop
    Write-Verbose "Building ps-runner"
    $gitUrl = "https://github.com/Privatix/dapp-installer.git"
    $PROJECT = "github.com\privatix\dapp-installer"

    # Check GOPATH is defined
    $gopath = $env:GOPATH
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env GOPATH"}
    if (!($gopath)) {throw "GOPATH is not defined"}
    if (!(Test-Path $gopath)) {New-Folder -rootFolder $gopath}
    $PROJECT_PATH = "$gopath\src\$PROJECT"
    $toolPath = "tool\ps-runner"

    Invoke-GoCommonOperations -gopath $gopath -project $PROJECT -godep $godep -branch $branch -gitpull $gitpull -giturl $gitUrl
    
    #region build

    $lastLocation = (Get-Location).Path
    Set-Location "$PROJECT_PATH\$toolPath"

    $error.Clear()

    try {
        Invoke-Scriptblock "go get $goVerbose -d  $PROJECT/$toolPath..."
        Invoke-Scriptblock "go get $goVerbose -u github.com/josephspurrier/goversioninfo/cmd/goversioninfo"
        Invoke-Scriptblock "go generate $goVerbose $PROJECT/$toolPath/..."
        Invoke-Scriptblock "go build -o $GOPATH/bin/ps-runner.exe"
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
