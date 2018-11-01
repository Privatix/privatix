#!/usr/bin/env bash

modified_repositories=()

start_release(){
    cd ${1}
    git flow release start ${2}
}

pull(){
    git checkout ${1}
    git pull
}

get_diff_count(){
    cd ${1}

    pull master
    pull develop

    return $(git diff develop master --name-status | wc -l)
}

collect_modified_repositories(){
    for repository in $@
    do
        printf '\n%s\n' ${repository}
        get_diff_count ${repository}
        if [ $? != "0" ]
        then
            modified_repositories+=(${repository})
        fi
    done
}


. ${1}
collect_modified_repositories ${REPOSITORIES[@]}
printf '\n\n\nModified repositories:\n'
printf '%s\n' ${modified_repositories[@]}
printf '\n\nNext operation:\n\ngit flow release start %s\n\nPress enter to continue...' ${RELEASE_VERSION}
read

for repository in ${modified_repositories[@]}
do
    start_release ${repository} ${RELEASE_VERSION}
done
