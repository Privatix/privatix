#!/usr/bin/env bash

PRIVATIX_APP_FOLDER=/Users/drew2a/Downloads/applications/Privatix

DESTINATION_FOLDER="${PRIVATIX_APP_FOLDER}/dump"

rm -rf "${DESTINATION_FOLDER}"
rm -rf "${DESTINATION_FOLDER}.zip"

find_and_copy(){
    mkdir -p "$2"

    find  "${PRIVATIX_APP_FOLDER}" -path "${DESTINATION_FOLDER}" -prune -o -name "$1" -exec \
        cp -v '{}' "$2" \;
}

find_and_copy "*.config.json" "${DESTINATION_FOLDER}/configs"
find_and_copy "settings.json" "${DESTINATION_FOLDER}/configs"
find_and_copy "*.log" "${DESTINATION_FOLDER}/logs"
find_and_copy "*.err" "${DESTINATION_FOLDER}/errs"

zip -r "${DESTINATION_FOLDER}" * || exit 1