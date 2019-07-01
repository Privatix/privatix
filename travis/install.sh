#!/usr/bin/env bash

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then

    # install debootstrap
    sudo apt-get install debootstrap -y
    sudo apt-get install systemd-container -y

    # bitrock
    #
    # download
    # https://installbuilder.bitrock.com/installbuilder-enterprise-19.5.0-linux-x64-installer.run
    downloading_binary=installbuilder-enterprise-${BITROCK_VERSION}-linux-x64-installer.run

    wget https://installbuilder.bitrock.com/${downloading_binary}
    chmod u+x ./${downloading_binary}

    # install
    ./${downloading_binary} --mode unattended || exit 1

    # add license
    cp "${TRAVIS_BUILD_DIR}/travis/encrypted/license.xml" \
       "${BITROCK_INSTALLER_LINUX}/license.xml" || exit 1
fi

#
# osx
#
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
    # bitrock
    #
    # download
    # https://installbuilder.bitrock.com/installbuilder-enterprise-19.5.0-osx-installer.dmg
    bitrock_installer=installbuilder-enterprise-${BITROCK_VERSION}-osx-installer

    curl -L -O https://installbuilder.bitrock.com/${bitrock_installer}.dmg

    # mount
    hdiutil attach -mountpoint ${bitrock_installer} ${bitrock_installer}.dmg

    # install
    "./${bitrock_installer}/${bitrock_installer}.app/Contents/MacOS/installbuilder.sh" --mode unattended || exit 1

    # add license
    cp "${TRAVIS_BUILD_DIR}/travis/encrypted/license.xml" \
       "${BITROCK_INSTALLER_MAC}/license.xml" || exit 1
fi

if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    # download and unpack static artefacts
    powershell -Command 'mkdir c:\art'
    powershell -Command 'curl.exe -L "http://artdev.privatix.net/artefacts_win.zip" --output c:\art\artefacts_win.zip'
    powershell -Command 'Expand-Archive -Path c:\art\artefacts_win.zip -DestinationPath c:\art'
    # download and install Bitrock installer
    powershell -Command 'mkdir c:\installbuilder'
    powershell -Command 'curl.exe -L "https://installbuilder.bitrock.com/installbuilder-enterprise-19.5.0-windows-x64-installer.exe" --output .\installbuilder-installer.exe'
    powershell -Command '.\installbuilder-installer.exe --mode unattended --prefix c:\installbuilder'
    # add license to Bitrock installer
    powershell -Command 'Copy-Item -Path "c:\Users\travis\gopath\src\github.com\Privatix\privatix\travis\encrypted\license.xml" -Destination "c:\installbuilder\"'
fi

    