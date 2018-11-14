# Script installs all prerequisites for build on Windows
# run following command prior execuring other commands. This will allow powershell scripts to run on machine.
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
# install chocolatey package manager for Windows
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# install golang
choco install golang -y
# install mingw, which includes gcc
choco install mingw -y 
# install nodejs with npm
choco install nodejs -y
# install git
choco install git -y
# uncomment below for OS version < 10 to get last powershell version
# choco install powershell -y 

New-Item -Path "$HOME\code" -ItemType Directory | Out-Null
Set-Location "$HOME\code"
git clone "https://github.com/Privatix/privatix.git"
Set-Location "$HOME\code\privatix"
git checkout develop
Set-Location "$HOME\code\privatix\build\win"
Write-Host "Use publish-dapp to build and package application" -ForegroundColor Green
Write-Host "Use new-package module (import it first using import-module) to package application" -ForegroundColor Green
Write-Host "Use other scripts to build particular repository" -ForegroundColor Green
Write-Host "run `"get-help publish-dapp -full`" to learn how to use it" -ForegroundColor Green

