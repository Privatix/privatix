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
    cp      "${TRAVIS_BUILD_DIR}/travis/encrypted/license.xml" \
            "${BITROCK_INSTALLER_MAC}/license.xml" || exit 1
fi