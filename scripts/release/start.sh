#!/usr/bin/env bash


repositories=(
            ~/Projects/github.com/Privatix/dapp-gui
            ~/Projects/github.com/Privatix/dapp-smart-contract
            ~/Projects/github.com/Privatix/dapp-somc
            ~/Projects/github.com/Privatix/privatix

            ~/go/src/github.com/privatix/dappctrl
            ~/go/src/github.com/privatix/dapp-installer
            ~/go/src/github.com/privatix/dapp-openvpn
)

start_release(){
    git flow release start ${1}
}

publish_release(){
    git flow release publish ${1}
}

process_repository(){
    repository=${1}
    release_version=${2}
    printf "\n------------------------------------------------------------------------------"
    printf "\nRepository: %s\n\n" ${repository}
    cd ${repository}

    git checkout master
    git pull
    git checkout develop
    git pull

    diff_count=$(git diff develop master --name-status | wc -l)
    printf "Differences between master and develop: %s" ${diff_count}

    if [ ${diff_count} != "0" ]
    then
        start_release ${release_version}
        return ${diff_count}
    fi

    return ${diff_count}
}

main(){
    printf "Enter the release version: "
    read release_version

    modified_repositories=""

    for repository in ${repositories[@]}
    do
        process_repository ${repository} ${release_version}
        result=$?
        if [ ${result} != "0" ]
        then
            modified_repositories="${modified_repositories}\n${repository}(${result})"
        fi
    done

    printf "\n\n\n==============================================================================="
    printf "\nModified repositories:\n"
    printf ${modified_repositories}
    printf "\n\nIn these repositories release has been started."
    printf "\nPlease, review the changes."
    printf "\n\n\nPress any key to push the changes to origin..."
    read

    for repository in ${repositories[@]}
    do
        cd ${repository}
        publish_release ${release_version}
    done

    printf "\n\n\nDone. Press any key to finish."
    read
}

main