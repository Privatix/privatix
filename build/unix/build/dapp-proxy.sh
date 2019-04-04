#!/usr/bin/env bash

#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.sealed.config

echo -----------------------------------------------------------------------
echo dapp-openvpn
echo -----------------------------------------------------------------------

build(){
    if [[ ! -d "${GOPATH}/bin/" ]]; then
        mkdir "${GOPATH}"/bin/ || exit 1
    fi

    cd "${DAPP_PROXY_DIR}" || exit 1

    ./scripts/build.sh || exit 1
}

build