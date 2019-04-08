function Invoke-Scriptblock {
    [CmdletBinding()]
    param
    (
        [string] $ScriptBlock,
        [string] $StderrPrefix = "ERR:",
        [int[]] $AllowedExitCodes = @(0),
        [switch] $ThrowOnError,
        [System.Management.Automation.ActionPreference]$erraction = "Continue"
    )
 
    $backupErrorActionPreference = $erraction     
    $script:ErrorActionPreference = "Continue"

    if (($VerbosePreference -eq 'SilentlyContinue') -or ($PSBoundParameters.ContainsKey('Verbose')) ) {
        $Quiet = $true
    }

    try {
        Write-Verbose "Executing: $ScriptBlock"
        $scrblk = [Scriptblock]::Create($ScriptBlock)
        . $scrblk 2>&1 | ForEach-Object -Process `
        {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                "$StderrPrefix$_"
            }
            elseif ($Quiet) {
                "$_"
            }
        }
        if ($ThrowOnError -and $AllowedExitCodes -notcontains $LASTEXITCODE) {
            Write-Host "failed to execute: $ScriptBlock" -ForegroundColor Red
            throw "Execution failed with exit code $LASTEXITCODE"
        }
    }
    finally {
        $script:ErrorActionPreference = $backupErrorActionPreference
    }
}

function Copy-Gitrepo {
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()][string]$path, 
        [ValidateNotNullOrEmpty()][string]$gitUrl
    ) 
    try {
        if (!(Test-Path $path)) { 
            New-Item -Path $path -ItemType Directory -ErrorAction Stop | Out-Null
            Invoke-Scriptblock -ScriptBlock "git.exe clone -q $gitUrl $path" -ThrowOnError -erraction $ErrorActionPreference
        }
        else {Write-Warning "directory $path already exists. Skipping git clone."}
    }
    catch {throw "failed to git clone $gitUrl to $path"}
}

function Find-App {
    [cmdletbinding()]    
    param
    (
        [ValidateNotNullorEmpty()]
        [string]$appname,
        [string]$versioncmd
    )
    $app = Get-Command $appname -ErrorAction SilentlyContinue
    if ($null -eq $app) { 
        throw "Unable to find $appname in %PATH"
    }
    
    if ($versioncmd) {
        try {
            $app = Invoke-Expression $versioncmd
            Write-Verbose "$appname version: $app"
            return $app
        }
        catch {
            throw "failed to execute $versioncmd"
        }
    }
    Write-Verbose "$appname version: $app"
    return $app.version
}

function New-Folder {
    [cmdletbinding()]
    param(
        [string]$rootFolder,
        [string]$childDirectory
    )
    try {
        $pth = Join-Path $rootFolder $childDirectory
        if (!(Test-Path $pth)) {
            Write-Verbose "Creating folder $pth"
            $newpath = New-Item $pth -ItemType Directory
            return $($newpath.FullName)
        }
    }
    catch {throw "Failed to create folder using $root as parent path and $childDirectory as child path. Original error: $($error[0].Exception.Message)"}
}

function Invoke-GoCommonOperations {
    [CmdletBinding()]
    param(        
        [string]$PROJECT_PATH,
        [string]$branch,
        [bool]$gitpull,
        [string]$gitUrl
    )
    #region checks
    
    # Check git exists
    Find-App -appname "git" -versioncmd "git.exe --version" | Out-Null

    # Check go installed
    Find-App -appname "go" -versioncmd "go.exe version" | Out-Null

    # Check gcc exists
    Find-App -appname "gcc" -versioncmd "gcc.exe --version" | Out-Null

    $gopath = $env:gopath
    if (!($gopath)) {$gopath = Invoke-Expression "go.exe env gopath"}
    if (!($gopath)) {throw "gopath is not defined"}    
    if (!(Test-Path $gopath)) {New-Folder -rootFolder $gopath}

    $srcPath = Split-Path -Path $PROJECT_PATH -Parent
    
    # Create go essential folders
    if (!(Test-Path $srcPath)) {New-Item -ItemType Directory -Path $srcPath | Out-Null}

    if (!(Test-Path $gopath\bin)) {New-Item -ItemType Directory -Path $gopath\bin | Out-Null}
    
    # Check gopath bin is on %PATH
    if (!((($env:PATH).split(";")) -contains "$gopath\bin") ) {throw "gopath bin is not found in %PATH. Please, resolve."}
    

    #region git

    Copy-Gitrepo -path $PROJECT_PATH -gitUrl $gitUrl -ErrorAction Stop
        
    #region Git checkout branch
    if ($PSBoundParameters.ContainsKey('branch')) {
        
        Checkout-Gitbranch -PROJECT_PATH $PROJECT_PATH -branch $branch
        
    }
    #endregion

    # Git pull
    if ($gitpull) {
        Pull-Git -PROJECT_PATH $PROJECT_PATH
    }
    else {Write-Warning "Skipping git pull"}
    #endregion
} 

function Checkout-Gitbranch {
    [CmdletBinding()]
    param (
        [ValidateScript({Test-Path $_ })]
        [string]$PROJECT_PATH,
        [string]$branch
    )
    
    if (($VerbosePreference -ne 'SilentlyContinue') -or ($PSBoundParameters.ContainsKey('Verbose')) ) {
        $gitQuiet = "-q"
    }

    Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH fetch --all $gitQuiet"
    Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH checkout $branch  $gitQuiet " -StderrPrefix ""
    $currentBranch = Invoke-Expression "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH rev-parse --abbrev-ref HEAD"
    if ($branch -ne $currentBranch) {
        $currentBranch = Invoke-Expression "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH rev-parse HEAD"
        if ($branch -ne $currentBranch) {throw "failed to chekout $branch"}
    }
}

function Pull-Git {
    [CmdletBinding()]
    param (
        [ValidateScript({Test-Path $_ })]
        [string]$PROJECT_PATH
    )
    
    if (($VerbosePreference -ne 'SilentlyContinue') -or ($PSBoundParameters.ContainsKey('Verbose')) ) {
        $gitQuiet = "-q"
    }

    Write-Host "Pulling from Git..."
    Invoke-Scriptblock -ScriptBlock "git.exe --git-dir=$PROJECT_PATH\.git --work-tree=$PROJECT_PATH pull" -StderrPrefix "" -erraction "Continue"
}