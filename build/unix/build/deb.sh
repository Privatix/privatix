#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.global.config

echo -----------------------------------------------------------------------
echo build deb
echo -----------------------------------------------------------------------

deb_dir="${BIN}/deb"
deb_package_name="privatix"
deb_bin_dir="${BIN}/deb"

deb_package_dir="${deb_bin_dir}/${deb_package_name}_ubuntu_x64_${VERSION_TO_SET_IN_BUILDER}_cli"

deb_package_control_dir="${deb_package_dir}/DEBIAN"
deb_package_bin_dir="${deb_package_dir}/opt/privatix_installer"


clear(){
    sudo rm -rf "${deb_dir}"
    mkdir -p "${deb_package_bin_dir}" || exit 1
    mkdir -p "${deb_package_control_dir}" || exit 1
}


copy(){
    cp -v "${GOPATH}/bin/${DAPP_INSTALLER}" \
          "${deb_package_bin_dir}/${DAPP_INSTALLER}" || exit 1

    cp -v "${GOPATH}/bin/${DAPP_SUPERVISOR}" \
          "${deb_package_bin_dir}/${DAPP_SUPERVISOR}" || exit 1

    echo "${DAPP_INSTALLER_DIR}/scripts/autooffer_rinkeby/ ->"
    echo "${deb_package_bin_dir}"
    cp -r "${DAPP_INSTALLER_DIR}/scripts/autooffer_rinkeby/" \
          "${deb_package_bin_dir}" || exit 1

    echo "${DAPPCTRL_DIR}/scripts/cli/ ->"
    echo "${deb_package_bin_dir}"
    cp -r "${DAPPCTRL_DIR}/scripts/cli/" \
          "${deb_package_bin_dir}" || exit 1

    cp -v "$1/app.tar.xz" \
          "${deb_package_bin_dir}/app.tar.xz" || exit 1

    echo "sudo ./dapp-installer install -workdir /var/lib/container/agent/ -role agent  -source ./app.zip -torhsd var/lib/tor/hidden_service -torsocks 9099 -sendremote false" \
	      >> "${deb_package_bin_dir}/install.sh" &&
    chmod +x "${deb_package_bin_dir}/install.sh" || exit 1

    echo "sudo ./dapp-installer remove -workdir /var/lib/container/agent/ -role agent" \
	      >> "${deb_package_bin_dir}/remove.sh" &&
    chmod +x "${deb_package_bin_dir}/remove.sh" || exit 1

    echo "sudo ./dapp-installer update -workdir /var/lib/container/agent/ -role agent" \
	      >> "${deb_package_bin_dir}/update.sh" &&
    chmod +x "${deb_package_bin_dir}/update.sh" || exit 1
}


create_info(){
	cat > "${deb_package_control_dir}/control" <<EOL
Package: ${deb_package_name}
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
	dpkg-deb --build "${deb_package_dir}"

    mv -v   "${deb_package_dir}.deb" \
            "$1"

    cd "$1"
    echo && echo
    ls -d $PWD/*
    echo && echo done
}


clear
copy $1
create_info
build $2


