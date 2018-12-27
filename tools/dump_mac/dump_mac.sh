#!/usr/bin/env bash

PRIVATIX_APP_FOLDER=/Applications/Privatix

DESTINATION_FOLDER="${PRIVATIX_APP_FOLDER}/dump"

rm -rf "${DESTINATION_FOLDER}"
rm -rf "${DESTINATION_FOLDER}".zip

find_and_copy(){
    mkdir -p "$2"

    find  "${PRIVATIX_APP_FOLDER}" -path "${DESTINATION_FOLDER}" -prune -o -name "$1" -exec \
        cp '{}' "$2" \;
}

get_value(){
    cat "${dappctrl_config}" | \
        python -c 'import json,sys;obj=json.load(sys.stdin);print obj["DB"]["Conn"]["'$1'"]';
}

echo "copying files..."
find_and_copy "*.config.json" "${DESTINATION_FOLDER}/configs"
find_and_copy "settings.json" "${DESTINATION_FOLDER}/configs"
find_and_copy "*.log" "${DESTINATION_FOLDER}/logs"
find_and_copy "*.err" "${DESTINATION_FOLDER}/errs"

dappctrl_config=$(find "${DESTINATION_FOLDER}"  -name "dappctrl.config.json")

echo "dumping db..."
find  "${PRIVATIX_APP_FOLDER}" -name "pg_dump" -exec \
   '{}' --create --column-inserts --clean --if-exists \
    -d "$(get_value "dbname")" \
    -h "$(get_value "host")" \
    -p "$(get_value "port")" \
    -U "$(get_value "user")" \
    -f "${DESTINATION_FOLDER}/db_dump.sql" \
     \;

echo "zipping files..."
zip -r "${DESTINATION_FOLDER}".zip "${DESTINATION_FOLDER}"