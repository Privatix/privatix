[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Prepare static artifacts
Invoke-WebRequest http://artdev.privatix.net/artefacts_win.zip -outFile c:/art/artefacts_win.zip
Expand-Archive -Path c:\art\artefacts_win.zip -DestinationPath C:\art
# Install BitRock IninstallBuilder
Invoke-WebRequest -URI https://installbuilder.bitrock.com/installbuilder-enterprise-$($env:BITROCK_VERSION)-windows-x64-installer.exe -OutFile .\installbuilder-installer.exe -UseBasicParsing
.\installbuilder-installer.exe --mode unattended --prefix c:\installbuilder
#Copy-Item $env:TRAVIS_BUILD_DIR\travis
