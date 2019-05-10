#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.global.config

build(){
    echo -----------------------------------------------------------------------
    echo build bitrock installer
    echo -----------------------------------------------------------------------

    # copy project
    cp -va "${DAPP_INSTALLER_DIR}/${INSTALL_BUILDER}/${INSTALL_BUILDER_PROJECT}" \
           "${PACKAGE_INSTALL_BUILDER_BIN}" || exit 1
    cd "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}" || exit 1

    # make replacement in project.xml
    [[ ! -z "$5" ]] && sed -i.b "$5" ${INSTALL_BUILDER_PROJECT_XML}

    # build installer
    "$1" build "${INSTALL_BUILDER_PROJECT_XML}" $2 \
                            --setvars project.version=${VERSION_TO_SET_IN_BUILDER} \
                                      product_id="$3" \
                                      product_name="$4" \
                                      forceUpdate="${DAPP_INSTALLER_FORCE_UPDATE}" \
                            || exit 1

    cd "${root_dir}"

    # move installer to out
    mv -v "${PACKAGE_INSTALL_BUILDER_BIN}/${INSTALL_BUILDER_PROJECT}/out" \
          "${PACKAGE_INSTALL_BUILDER_BIN}" || exit 1
    cd "${PACKAGE_INSTALL_BUILDER_BIN}/out"

    echo && echo
    ls -d $PWD/*
    echo && echo done
}

build "$1" "$2" "$3" "$4" "$5"