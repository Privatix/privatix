[CmdletBinding()]
param(
    [string]$wkdir = "c:\privatix\",
    [ValidateScript( {Test-Path $_ })]
    [string]$staticArtefactsDir = "c:\privatix\art",
    [switch]$pack,
    [string]$dappguibranch = "develop",
    [string]$dappctrlbranch = "develop",
    [string]$dappinstbranch = "develop",
    [string]$dappopenvpnbranch = "develop",
    [switch]$godep,
    [switch]$gitpull
)
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $global:VerbosePreference = [System.Management.Automation.ActionPreference]::Continue
}
$builddapp = (Join-Path $PSScriptRoot build-dapp.ps1 -Resolve -ErrorAction Stop)
Import-Module (Join-Path $PSScriptRoot "new-package.psm1" -Resolve) -ErrorAction Stop -DisableNameChecking

. $builddapp -dappctrl -branch $dappctrlbranch -gitpull:$gitpull -godep:$godep
. $builddapp -dappopenvpn -branch $dappopenvpnbranch -gitpull:$gitpull -godep:$godep
. $builddapp -dappinstaller -branch $dappinstbranch -gitpull:$gitpull -godep:$godep
if ($pack) {
    . $builddapp -dappgui -branch $dappguibranch -gitpull:$gitpull -wd $wkdir -package
    new-package -wrkdir $wkdir -staticArtefactsDir $staticArtefactsDir
}
else {. $builddapp -dappgui -branch $dappguibranch -gitpull:$gitpull -wd $wkdir -shortcut}
Remove-Module new-package
