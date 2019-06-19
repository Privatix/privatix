#!/usr/bin/env bash

root_dir="$(cd `dirname $0` && pwd)/.."
cd ${root_dir}
. ./build.global.config

project_xml=Privatix.xml
project_name=project
#Error: Cannot add /Users/drew2a/Projects/github.com/Privatix/privatix/build/unix/bin/proxy/mac/mac-dapp-installer/app.zip to packed archive. File does not exist
build(){
    echo -----------------------------------------------------------------------
    echo build bitrock installer
    echo -----------------------------------------------------------------------

    # copy project
    cp -va "${DAPP_INSTALLER_DIR}/installbuilder/${project_name}" \
           "$6" || exit 1
    cd "$6/${project_name}" || exit 1

    # make replacement in project.xml
    [[ ! -z "$5" ]] && sed -i.b "$5" ${project_xml}

    # build installer
    "$1" build "${project_xml}" $2 \
                            --setvars project.version=${VERSION_TO_SET_IN_BUILDER} \
                                      product_id="$3" \
                                      product_name="$4" \
                                      forceUpdate="${DAPP_INSTALLER_FORCE_UPDATE}" \
                                      project.outputDirectory="$7" \
                            || exit 1

    cd "$7"

    echo && echo
    ls -d $PWD/*
    echo && echo done
}

build "$1" "$2" "$3" "$4" "$5" "$6" "$7"