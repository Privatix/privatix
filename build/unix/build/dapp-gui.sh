#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.sealed.config

echo -----------------------------------------------------------------------
echo dapp-gui
echo -----------------------------------------------------------------------

clean(){
    cd "${DAPP_GUI_DIR}" || exit 1

    rm -rf ./build/ || exit 1
    rm -rf ./release-builds/ || exit 1
}

make_packages(){
    npm i || exit 1
    npm run build || exit 1

    echo
    echo run $1
    echo

    npm run $1 || exit 1

    echo
    echo copy $2 "->" $3
    echo

    cd ${root_dir} || exit 1
    rsync -azhP "$2" \
                "$3" || exit 1

    # patch settings.json
    python -c 'import json, sys
with open(sys.argv[1], "r") as f:
    obj = json.load(f)
obj["release"]="'${VERSION_TO_SET_IN_BUILDER}'"
obj["target"]="osx"
with open(sys.argv[1], "w") as f:
   json.dump(obj, f)' \
   "$5/${DAPP_INSTALLER_GUI_DIR}/${DAPP_INSTALLER_GUI_BINARY_NAME}/$4" || exit 1

}

clean
make_packages "$1" "$2" "$3" "$4" "$5"