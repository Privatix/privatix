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