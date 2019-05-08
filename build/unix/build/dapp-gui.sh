#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.global.config

echo -----------------------------------------------------------------------
echo build dapp-gui
echo -----------------------------------------------------------------------

clean(){
    cd "${DAPP_GUI_DIR}" || exit 1

    rm -rf ./build/ || exit 1
    rm -rf ./release-builds/ || exit 1
}

make_packages(){
    npm i || exit 1
    npm run build || exit 1

    echo && echo run $1 && echo

    npm run $1 || exit 1

    echo && echo copy $2 "->" && echo $3 && echo

    cd ${root_dir} || exit 1
    cp -r "$2" \
          "$3" || exit 1

   "${PATCH_JSON_SH}" "$3/$4" \
                      '["release"]="'"${VERSION_TO_SET_IN_BUILDER}"'"' \
                      '["target"]="'"${5}"'"' \
                      || exit 1

   echo && echo done

}

clean
make_packages "$1" "$2" "$3" "$4" "$5"