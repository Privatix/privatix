<#
.Synopsis
   Remove binaries from go/bin
.DESCRIPTION
   Remove binaries from go/bin. Use prior run new build to ensure that old binaries do not copied during artefact preparation.

.EXAMPLE
   remove-binaries

   Description
   -----------
   Remove all privatix binaries from go/bin.
#>
$ErrorActionPreference = "Stop"
$gopath = $env:GOPATH
if (!($gopath)) {$gopath = Invoke-Expression "go.exe env GOPATH"}
if (!($gopath)) {throw "GOPATH is not defined"}
$bin = Join-Path -Path $gopath -ChildPath "bin" -Resolve
if (!($bin)) {throw "$bin doesn't exists"}
if (Test-Path "$bin\dappctrl.exe") { Remove-Item -Path "$bin\dappctrl.exe"}
if (Test-Path "$bin\dappvpn.exe") { Remove-Item -Path "$bin\dappvpn.exe"}
if (Test-Path "$bin\inst.exe") { Remove-Item -Path "$bin\inst.exe"}
if (Test-Path "$bin\installer.exe") { Remove-Item -Path "$bin\installer.exe"}
if (Test-Path "$bin\dapp-installer.exe") { Remove-Item -Path "$bin\dapp-installer.exe"}