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

    cp -v "${DAPP_INSTALLER_DIR}/${DAPP_INSTALLER_LINUX_CONFIG}" \
          "${deb_package_bin_dir}/${DAPP_INSTALLER_CONFIG}" || exit 1

    cp -v "$1/app.tar.xz" \
          "${deb_package_bin_dir}/app.tar.xz" || exit 1

    echo "sudo ./dapp-installer install --config dapp-installer.config.json" \
	      >> "${deb_package_bin_dir}/install.sh" &&
    chmod +x "${deb_package_bin_dir}/install.sh" || exit 1

    echo "sudo ./dapp-installer remove --workdir /var/lib/container/agent/" \
	      >> "${deb_package_bin_dir}/remove.sh" &&
    chmod +x "${deb_package_bin_dir}/remove.sh" || exit 1

    echo "wget https://raw.githubusercontent.com/Privatix/dapp-installer/master/scripts/autooffer/autooffer.py " \
	      >> "${deb_package_bin_dir}/get_autooffer.sh" &&
    chmod +x "${deb_package_bin_dir}/get_autooffer.sh" || exit 1

    echo "sudo python /opt/privatix_installer/autooffer.py" \
	      >> "${deb_package_bin_dir}/publish_offering.sh" &&
    chmod +x "${deb_package_bin_dir}/publish_offering.sh" || exit 1

    cat > "${deb_package_bin_dir}/install_and_publish.sh" <<EOL
#!/usr/bin/env bash

./install.sh &&
./get_autooffer.sh &&
sleep 10 &&
./publish_offering.sh
EOL
    chmod +x "${deb_package_bin_dir}/install_and_publish.sh" || exit 1

}


patch(){
	"${PATCH_JSON_SH}" "${deb_package_bin_dir}/${DAPP_INSTALLER_CONFIG}" \
              '["Role"]="agent"' \
              '["Path"]="/var/lib/container/agent"' \
              || exit 1
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
patch
create_info
build $2


