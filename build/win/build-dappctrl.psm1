<#
.SYNOPSIS
    Build Privatix controller (dappctrl) on Windows
.DESCRIPTION
    Build Privatix controller (dappctrl) on Windows

.PARAMETER branch
    Checkout existing git branch

.PARAMETER gitpull
    Pull from git

.PARAMETER godep
    Use go dependency

.EXAMPLE
    build-dappctrl

    Description
    -----------
    Build dappctrl.

.EXAMPLE
    build-dappctrl -branch "develop" -godep -gitpull

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
        [switch]$godep
    )
    
    $gitQuiet = "-q"
    if ($VerbosePreference -ne 'SilentlyContinue') {
        $goVerbose = ' -v '
        $gitQuiet = ""
    }
    Write-Verbose "Building dappctrl"

    $gitUrl = "https://github.com/Privatix/dappctrl.git"

    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop

    #region checks
    $PROJECT = "github.com\privatix\dappctrl"
    
    # Check git exists
    $ver = Find-App -appname "git" -versioncmd "git.exe --version"

    # Check go installed
    $ver = Find-App -appname "go" -versioncmd "go.exe version"

    # Check gcc exists
    $ver = Find-App -appname "gcc" -versioncmd "gcc.exe --version"

    # Check GOPATH is defined
    $gopath = $env:GOPATH
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env GOPATH"}
    if (!($gopath)) {throw "GOPATH is not defined"}
    
    if (!(Test-Path $gopath)) {throw "GOPATH $gopath do not exists"}

    $PROJECT_PATH = "$gopath\src\$PROJECT"

    # Create go essential folders
    if (!(Test-Path $gopath\src)) {New-Item -ItemType Directory -Path $gopath\src | Out-Null}

    if (!(Test-Path $gopath\bin)) {New-Item -ItemType Directory -Path $gopath\bin | Out-Null}
    
    # Check GOPATH bin is on %PATH
    if (!((($env:PATH).split(";")) -contains "$gopath\bin") ) {throw "GOPATH bin is not found in %PATH. Please, resolve."}

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
        
    #Invoke-Scriptblock -ScriptBlock {git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH status}
        
    #region Git checkout branch
    if ($PSBoundParameters.ContainsKey('branch')) {
        Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH fetch --all $gitQuiet"
        Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH checkout $branch  $gitQuiet "
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
        Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH pull $gitQuiet" -StderrPrefix "" -erraction "Continue"
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
            Invoke-Expression "$gopath\bin\dep.exe ensure $goVerbose"
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
        Invoke-Scriptblock "go get $goVerbose -d  $PROJECT/..."
        Invoke-Scriptblock "go get $goVerbose -u gopkg.in/reform.v1/reform"
        Invoke-Scriptblock "go get $goVerbose -u github.com/rakyll/statik"
        Invoke-Scriptblock "go get $goVerbose -u github.com/pressly/goose/cmd/goose"
        Invoke-Scriptblock "go get $goVerbose github.com/ethereum/go-ethereum/cmd/abigen"
        Invoke-Scriptblock "go generate $goVerbose $PROJECT/..."
        Invoke-Scriptblock "go install $goVerbose -ldflags `"-X main.Commit=$GIT_COMMIT -X main.Version=$GIT_RELEASE`" -tags=notest $PROJECT"
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
