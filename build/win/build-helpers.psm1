function Install-GoDep {
    [CmdletBinding()]
    param(
        $path
    )
    # Set TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    # discover environment
    $osArch = ($ENV:PROCESSOR_ARCHITECTURE).ToLower()
    
    try {
        $RunGoDepLatest = Invoke-WebRequest "https://api.github.com/repos/golang/dep/releases/latest" | ConvertFrom-Json
        $RunGoDepLatestObj = $RunGoDepLatest.assets | Where-Object {$_.name -eq ("dep-windows-" + $osArch + ".exe")}
    }
    catch {
        throw "Failed to parse go dep release from github"
    }

    try {
        Invoke-WebRequest -Uri $RunGoDepLatestObj.browser_download_url -OutFile "$path\bin\dep.exe"
    }
    catch {
        throw "Failed to download and save latest go dep from github"
    }
}


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

    try {
        Write-Verbose "Executing: $ScriptBlock"
        $scrblk = [Scriptblock]::Create($ScriptBlock)
        . $scrblk 2>&1 | ForEach-Object -Process `
        {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                "$StderrPrefix$_"
            }
            else {
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

Function New-Shortcut {
    <#  
.SYNOPSIS  
    This script is used to create a  shortcut.        
.DESCRIPTION  
    This script uses a Com Object to create a shortcut.
.PARAMETER Path
    The path to the shortcut file.  .lnk will be appended if not specified.  If the folder name doesn't exist, it will be created.
.PARAMETER TargetPath
    Full path of the target executable or file.
.PARAMETER Arguments
    Arguments for the executable or file.
.PARAMETER Description
    Description of the shortcut.
.PARAMETER HotKey
    Hotkey combination for the shortcut.  Valid values are SHIFT+F7, ALT+CTRL+9, etc.  An invalid entry will cause the 
    function to fail.
.PARAMETER WorkDir
    Working directory of the application.  An invalid directory can be specified, but invoking the application from the 
    shortcut could fail.
.PARAMETER WindowStyle
    Windows style of the application, Normal (1), Maximized (3), or Minimized (7).  Invalid entries will result in Normal
    behavior.
.PARAMETER Icon
    Full path of the icon file.  Executables, DLLs, etc with multiple icons need the number of the icon to be specified, 
    otherwise the first icon will be used, i.e.:  c:\windows\system32\shell32.dll,99
.PARAMETER admin
    Used to create a shortcut that prompts for admin credentials when invoked, equivalent to specifying runas.
.NOTES  
    Author		: Rhys Edwards
    Email		: powershell@nolimit.to (https://gallery.technet.microsoft.com/scriptcenter/New-Shortcut-4d6fb3d8)  
.INPUTS
    Strings and Integer
.OUTPUTS
    True or False, and a shortcut
.LINK  
    Script posted over:  N/A  
.EXAMPLE  
    New-Shortcut -Path c:\temp\notepad.lnk -TargetPath c:\windows\notepad.exe    
    Creates a simple shortcut to Notepad at c:\temp\notepad.lnk
.EXAMPLE
    New-Shortcut "$($env:Public)\Desktop\Notepad" c:\windows\notepad.exe -WindowStyle 3 -admin
    Creates a shortcut named Notepad.lnk on the Pu	blic desktop to notepad.exe that launches maximized after prompting for 
    admin credentials.
.EXAMPLE
    New-Shortcut "$($env:USERPROFILE)\Desktop\Notepad.lnk" c:\windows\notepad.exe -icon "c:\windows\system32\shell32.dll,99"
    Creates a shortcut named Notepad.lnk on the user's desktop to notepad.exe that has a pointy finger icon (on Windows 7).
.EXAMPLE
    New-Shortcut "$($env:USERPROFILE)\Desktop\Notepad.lnk" c:\windows\notepad.exe C:\instructions.txt
    Creates a shortcut named Notepad.lnk on the user's desktop to notepad.exe that opens C:\instructions.txt 
.EXAMPLE
    New-Shortcut "$($env:USERPROFILE)\Desktop\ADUC" %SystemRoot%\system32\dsa.msc -admin 
    Creates a shortcut named ADUC.lnk on the user's desktop to Active Directory Users and Computers that launches after 
    prompting for admin credentials
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, Position = 0)] 
        [Alias("File", "Shortcut")] 
        [string]$Path,

        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True, Position = 1)] 
        [Alias("Target")] 
        [string]$TargetPath,

        [Parameter(ValueFromPipelineByPropertyName = $True, Position = 2)] 
        [Alias("Args", "Argument")] 
        [string]$Arguments,

        [Parameter(ValueFromPipelineByPropertyName = $True, Position = 3)]  
        [Alias("Desc")]
        [string]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $True, Position = 4)]  
        [string]$HotKey,

        [Parameter(ValueFromPipelineByPropertyName = $True, Position = 5)]  
        [Alias("WorkingDirectory", "WorkingDir")]
        [string]$WorkDir,

        [Parameter(ValueFromPipelineByPropertyName = $True, Position = 6)]  
        [int]$WindowStyle,

        [Parameter(ValueFromPipelineByPropertyName = $True, Position = 7)]  
        [string]$Icon,

        [Parameter(ValueFromPipelineByPropertyName = $True)]  
        [switch]$admin
    )


    Process {

        If (!($Path -match "^.*(\.lnk)$")) {
            $Path = "$Path`.lnk"
        }
        [System.IO.FileInfo]$Path = $Path
        Try {
            If (!(Test-Path $Path.DirectoryName)) {
                mkdir $Path.DirectoryName -ErrorAction Stop | Out-Null
            }
        }
        Catch {
            Write-Verbose "Unable to create $($Path.DirectoryName), shortcut cannot be created"
            Return $false
            Break
        }


        # Define Shortcut Properties
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($Path.FullName)
        $Shortcut.TargetPath = $TargetPath
        $Shortcut.Arguments = $Arguments
        $Shortcut.Description = $Description
        $Shortcut.HotKey = $HotKey
        $Shortcut.WorkingDirectory = $WorkDir
        $Shortcut.WindowStyle = $WindowStyle
        If ($Icon) {
            $Shortcut.IconLocation = $Icon
        }

        Try {
            # Create Shortcut
            $Shortcut.Save()
            # Set Shortcut to Run Elevated
            If ($admin) {     
                $TempFileName = [IO.Path]::GetRandomFileName()
                $TempFile = [IO.FileInfo][IO.Path]::Combine($Path.Directory, $TempFileName)
                $Writer = New-Object System.IO.FileStream $TempFile, ([System.IO.FileMode]::Create)
                $Reader = $Path.OpenRead()
                While ($Reader.Position -lt $Reader.Length) {
                    $Byte = $Reader.ReadByte()
                    If ($Reader.Position -eq 22) {$Byte = 34}
                    $Writer.WriteByte($Byte)
                }
                $Reader.Close()
                $Writer.Close()
                $Path.Delete()
                Rename-Item -Path $TempFile -NewName $Path.Name | Out-Null
            }
            Return $True
        }
        Catch {
            Write-Verbose "Unable to create $($Path.FullName)"
            Write-Verbose $Error[0].Exception.Message
            Return $False
        }

    }
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
        [string]$gopath,
        [string]$PROJECT,
        [bool]$godep,
        [string]$branch,
        [bool]$gitpull,
        [string]$gitUrl
    )
    $gitQuiet = "-q"
    if (($VerbosePreference -ne 'SilentlyContinue') -or ($PSBoundParameters.ContainsKey('Verbose')) ) {
        $goVerbose = ' -v '
        $gitQuiet = ""
    }
    #region checks
    
    # Check git exists
    Find-App -appname "git" -versioncmd "git.exe --version" | Out-Null

    # Check go installed
    Find-App -appname "go" -versioncmd "go.exe version" | Out-Null

    # Check gcc exists
    Find-App -appname "gcc" -versioncmd "gcc.exe --version" | Out-Null

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
    if (!$GoDepInstalled -and $godep -and ($null -ne (Install-GoDep($gopath)))) {        
        Write-Warning "Failed to install go dep"
    }
    else {$GoDepInstalled = $true}

    #region git

    Copy-Gitrepo -path $PROJECT_PATH -gitUrl $gitUrl -ErrorAction Stop
        
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
} 