#!/usr/bin/env bash

#
# ubuntu
#
if [ "$TRAVIS_OS_NAME" = "linux" ]; then

    # install debootstrap
    sudo apt-get install debootstrap -y || exit 1
    sudo apt-get install systemd-container -y || exit 1

    # bitrock
    #
    # download
    set -x

    wget "${BITROCK_INSTALLER_URL_LINUX}" || exit 1

    downloading_binary=$(basename "${BITROCK_INSTALLER_URL_LINUX}")
    chmod u+x "./${downloading_binary}" || exit 1

    # install
    echo install: "./${downloading_binary}" --mode unattended || exit 1
    "./${downloading_binary}" --mode unattended || exit 1

    set +x
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
    set -x

    curl -LOf "${BITROCK_INSTALLER_URL_MAC}" || exit 1
    bitrock_installer=$(basename "${BITROCK_INSTALLER_URL_MAC}" .dmg)

    # mount
    hdiutil attach -mountpoint "${bitrock_installer}" "${bitrock_installer}.dmg" || exit 1

    # install
    "./${bitrock_installer}/${bitrock_installer}.app/Contents/MacOS/installbuilder.sh" --mode unattended || exit 1

    # add license
    set +x
    cp "${TRAVIS_BUILD_DIR}/travis/encrypted/license.xml" \
       "${BITROCK_INSTALLER_MAC}/license.xml" || exit 1
fi

if [ "$TRAVIS_OS_NAME" = "windows" ]; then
    # download and unpack static artefacts
    powershell -Command 'mkdir c:\art'
    powershell -Command 'curl.exe -Lfo c:\art\artefacts_win.zip https://github.com/Privatix/privatix/releases/download/1.2.0/artefacts_win.zip'
    powershell -Command 'Expand-Archive -Path c:\art\artefacts_win.zip -DestinationPath c:\art'
    # download and install Bitrock installer
    powershell -Command 'mkdir c:\installbuilder'
    powershell -Command 'curl.exe -Lfo c:\bitrock-installer.exe "'${BITROCK_INSTALLER_URL_WIN}'"'
    powershell -Command 'c:\bitrock-installer.exe --mode unattended --prefix c:\installbuilder'
    # add license to Bitrock installer
    powershell -Command 'Copy-Item -Path "c:\Users\travis\gopath\src\github.com\Privatix\privatix\travis\encrypted\license.xml" -Destination "c:\installbuilder\"'
fi

    