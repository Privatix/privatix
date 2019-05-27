#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.global.config

echo -----------------------------------------------------------------------
echo build deb
echo -----------------------------------------------------------------------

DEB_DIR="${BIN}/deb"
DEB_PACKAGE_NAME="privatix"
DEB_BIN_DIR="${BIN}/deb"
DEB_PACKAGE_DIR="${DEB_BIN_DIR}/${DEB_PACKAGE_NAME}_ubuntu_x64_${VERSION_TO_SET_IN_BUILDER}_cli"
DEB_PACKAGE_CONTROL_DIR="${DEB_PACKAGE_DIR}/DEBIAN"
DEB_PACKAGE_BIN_DIR="${DEB_PACKAGE_DIR}/opt/privatix_installer"


clear(){
    sudo rm -rf "${DEB_DIR}"
    mkdir -p "${DEB_PACKAGE_BIN_DIR}" || exit 1
    mkdir -p "${DEB_PACKAGE_CONTROL_DIR}" || exit 1
}


copy(){
    cp -v "${GOPATH}/bin/${DAPP_INSTALLER}" \
          "${DEB_PACKAGE_BIN_DIR}/${DAPP_INSTALLER}" || exit 1

    cp -v "${DAPP_INSTALLER_DIR}/${DAPP_INSTALLER_LINUX_CONFIG}" \
          "${DEB_PACKAGE_BIN_DIR}/${DAPP_INSTALLER_CONFIG}" || exit 1

    cp -v "${PACKAGE_BIN_LINUX}/app.tar.xz" \
          "${DEB_PACKAGE_BIN_DIR}/app.tar.xz" || exit 1

    echo "sudo ./dapp-installer install --config dapp-installer.config.json" \
	      >> "${DEB_PACKAGE_BIN_DIR}/install.sh" &&
    chmod +x "${DEB_PACKAGE_BIN_DIR}/install.sh" || exit 1

    echo "sudo ./dapp-installer remove --workdir /var/lib/container/agent/" \
	      >> "${DEB_PACKAGE_BIN_DIR}/remove.sh" &&
    chmod +x "${DEB_PACKAGE_BIN_DIR}/remove.sh" || exit 1

    echo "wget https://raw.githubusercontent.com/Privatix/dapp-installer/master/scripts/autooffer/autooffer.py " \
	      >> "${DEB_PACKAGE_BIN_DIR}/get_autooffer.sh" &&
    chmod +x "${DEB_PACKAGE_BIN_DIR}/get_autooffer.sh" || exit 1

    echo "sudo python /opt/privatix_installer/autooffer.py" \
	      >> "${DEB_PACKAGE_BIN_DIR}/publish_offering.sh" &&
    chmod +x "${DEB_PACKAGE_BIN_DIR}/publish_offering.sh" || exit 1

    cat > "${DEB_PACKAGE_BIN_DIR}/install_and_publish.sh" <<EOL
#!/usr/bin/env bash

./install.sh &&
./get_autooffer.sh &&
sleep 10 &&
./publish_offering.sh
EOL
    chmod +x "${DEB_PACKAGE_BIN_DIR}/install_and_publish.sh" || exit 1

}


patch(){
	"${PATCH_JSON_SH}" "${DEB_PACKAGE_BIN_DIR}/${DAPP_INSTALLER_CONFIG}" \
              '["Role"]="agent"' \
              '["Path"]="/var/lib/container/agent"' \
              || exit 1
}

create_info(){
	cat > "${DEB_PACKAGE_CONTROL_DIR}/control" <<EOL
Package: ${DEB_PACKAGE_NAME}
Version: ${VERSION_TO_SET_IN_BUILDER}
Section: base
Priority: optional
Architecture: amd64
Depends:
Maintainer: Privatix <admin@privatix.io>
Description: Privatix CLI

EOL

}

build(){
	dpkg-deb --build "${DEB_PACKAGE_DIR}"

    cd "${DEB_BIN_DIR}"

    echo && echo
    ls -d $PWD/*
    echo && echo done
}

clear
copy
patch
create_info
build


