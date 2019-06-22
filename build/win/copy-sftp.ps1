
param(
    [string]$FTP_pass = "",
    [string]$FTP_user = "",
    [string]$FTP_host = "",
    [string]$FTP_ssh_fingerprint = "ssh-ed25519 256 3qtI9A9xqKLGWgpwKgwmVIHkz/D4vskm2EtIXn88AlM=",
    [string]$WinSCP_version = "5.15.2",
    [string]$NugetVersion = "2.8.5.208",
    [string]$FTP_travis_root = "/home/sites/nspawn/travis",
    [string]$git_branch_name = "test",
    [string]$destination = "2019_01_01-build002",
    [string]$VPN_WIN_OUTPUT_DIR = "vpn_win",
    [string]$sourceFile = "$home\desktop\build\file1.txt"
)

if (-not (Test-Path $sourceFile)) {
    Write-Error "Nothing to copy. File `"$sourceFile`" not found."
    exit 1
}

try {
    Get-PackageProvider -Name "NuGet"
}
catch {
    try {Install-PackageProvider -Name NuGet -RequiredVersion $NugetVersion -Force}
    catch {
        Write-Error "Failed to install NuGet PackageProvider. Original exception: $error[0].exception"
        exit 1
    }
}

try {Get-Module -Name WinSCP}
catch{Install-Package WinSCP -RequiredVersion $WinSCP_version -Force}

try {
    Import-Module -Name WinSCP
}
catch {
    Write-Error "Failed to import WinSCP module. Original exception: $error[0].exception"
    exit 1
}

$password = ConvertTo-SecureString $FTP_pass -AsPlainText -Force

$cred = New-Object System.Management.Automation.PSCredential ($FTP_user, $password)

$sessionOption = New-WinSCPSessionOption -HostName $FTP_host -Protocol Sftp -SshHostKeyFingerPrint $FTP_ssh_fingerprint -Credential $cred
$session = New-WinSCPSession -SessionOption $sessionOption

$FTP_path = $FTP_travis_root + "/" + $git_branch_name + "/" + $destination + "/" + $VPN_WIN_OUTPUT_DIR

Write-Host "Creating folders for path: $FTP_path"

$path_to_create = ""
foreach ($path_folder in $FTP_path.Split("/")) {
    $path_to_create +=  $path_folder + "/"
    if (-not $session.FileExists($path_to_create)) {$session.CreateDirectory($path_to_create)}
}

if (-not $session.FileExists($FTP_path)) {
    Write-Error "Failed to create directories on FTP. Original exception: $error[0].exception"
    exit 1
}

try {
    $filename = (Get-Item -Path $sourceFile).Name
    $destination_file = $FTP_path + "/" + $filename
    $transferResult = $session.PutFiles($sourceFile,$destination_file,$false,$null)
    $transferResult.Check()
}
catch {
    Write-Error "Something went wrong during FTP copy. Original exception: $error[0].exception"
    exit 1
}

$session.Close()