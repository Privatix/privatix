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

.EXAMPLE
    build-dappinstaller

    Description
    -----------
    Build Dappinstaller.

.EXAMPLE
    build-dappinstaller -branch "develop" -godep -gitpull

    Description
    -----------
    Checkout branch "develop". Pull from git. Run go dependecy. Build dapp-installer.
#>
Function build-dappinstaller {
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

    Write-Verbose "Building dapp-installer"

    $gitUrl = "https://github.com/Privatix/dapp-installer.git"

    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop

    #region checks
    $PROJECT = "github.com\privatix\dapp-installer"
    

    # Check git exists
    try {
        $gitversion = Invoke-Expression "git.exe --version"
        if ($gitversion) {
            Write-Verbose "$gitversion found installed"
        }
    } 
    catch {throw "Git is not installed or not in %PATH"}
        
    # Check go installed
    try {
        $goversion = Invoke-Expression "go.exe version"
        if ($goversion) {Write-Verbose "$goversion found installed"}
    } 
    catch {throw "Go is not installed or not in %PATH"}
    
    # Check gcc exists
    try {
        $gccversion = Invoke-Expression "gcc.exe --version"
        if ($gccversion) {
            Write-Verbose "gcc found installed. gcc version info:`n $gccversion"
        }
    } 
    catch {throw "gcc is not installed or not in %PATH"}

    # Check GOPATH is defined
    $gopath = $env:GOPATH
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env GOPATH"}
    if (!($gopath)) {throw "GOPATH is not defined"}
    
    if (!(Test-Path $gopath)) {throw "GOPATH $gopath do not exists"}

    $PROJECT_PATH = "$gopath\src\$PROJECT"

    # Create essential folders
    if (!(Test-Path $gopath\src)) {New-Item -ItemType Directory -Path $gopath\src | Out-Null}

    if (!(Test-Path $gopath\bin)) {New-Item -ItemType Directory -Path $gopath\bin | Out-Null}
    
    # Check GOPATH bin is on %PATH
    if (!((($env:PATH).split(";")) -contains "$gopath\bin") ) {throw "GOPATH bin is not found in %PATH"}

    #Check go dep installed
    if (Test-Path "$gopath\bin\dep.exe") {
        Write-Verbose "Go dep is installed"
        $GoDepInstalled = $true
    } 
    #endregion
   
    # Install go dep
    if (!$GoDepInstalled -and $godep -and (Install-GoDep($gopath) -ne $null)) {        
        Write-Warning "Failed to install go dep"
    }
    else {$GoDepInstalled = $true}

    #region git

    Copy-Gitrepo -path $PROJECT_PATH -gitUrl $gitUrl -ErrorAction Stop
        
    Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH status"
        
    #region Git checkout branch
    Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH fetch --all"
    if ($PSBoundParameters.ContainsKey('branch')) {
        Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH checkout $branch"
        $currentBranch = Invoke-Expression "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH rev-parse --abbrev-ref HEAD"
        if ($branch -ne $currentBranch) {
            $currentBranch = Invoke-Expression "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH rev-parse HEAD"    
            if ($branch -ne $currentBranch) {throw "failed to chekout $branch"}
        }
    }
    #endregion

    # Git pull
    if ($gitpull) {
        Write-Host "Pulling from Git..."
        Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH pull" -StderrPrefix "" -erraction "Continue"
    }
    else {Write-Warning "Skipping git pull"}
    #endregion

    #region go dep
    # Go dep
    If ($godep -and $GoDepInstalled) {
        try {
            Write-Host "executing dep ensure..."
            $lastLocation = (Get-Location).Path
            Set-Location $PROJECT_PATH
            if ($VerbosePreference -ne "SilentlyContinue") {
                Invoke-Expression "$gopath\bin\dep.exe ensure -v"
            }
            else {Invoke-Expression "$gopath\bin\dep.exe ensure"}
        }
        catch {
            Write-Error "dep ensure execution failed"
        }
        finally {Set-Location $lastLocation}
    }
    else {Write-Warning "Skipping dep ensure"}

    #endregion

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
