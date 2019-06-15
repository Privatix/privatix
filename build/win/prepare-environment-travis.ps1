$static_artefact_zip = 'artefacts_win.zip'
$static_artefacts_url = 'http://artdev.privatix.net/' + $static_artefact_zip
$static_art_folder = "c:\art"
$bitrock_folder = "c:\installbuilder"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Prepare static artifacts
mkdir $static_art_folder
Invoke-WebRequest -Uri $static_artefacts_url -OutFile ($static_art_folder + $static_artefact_zip)
Expand-Archive -Path ($static_art_folder + $static_artefact_zip) -DestinationPath $static_art_folder

# Install BitRock IninstallBuilder
Write-Host "`n Bitrock version: $env:BITROCK_VERSION `n"
$bitrock_url = "https://installbuilder.bitrock.com/installbuilder-enterprise-$($env:BITROCK_VERSION)-windows-x64-installer.exe"
Write-Host "Downloading Bitirock from: $bitrock_url"
Invoke-WebRequest -URI $bitrock_url -OutFile .\installbuilder-installer.exe -UseBasicParsing
mkdir $bitrock_folder
.\installbuilder-installer.exe --mode unattended --prefix $bitrock_folder
ls $bitrock_folder