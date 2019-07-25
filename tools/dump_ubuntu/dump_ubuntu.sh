#!/usr/bin/env bash

if (( "$#" > 1 ));
then
    echo usage: dump_ubuntu.sh [privatix_app_folder_path]
    exit 1
fi

PRIVATIX_APP_FOLDER=${1:-/opt/Privatix}

DESTINATION_FOLDER="${PRIVATIX_APP_FOLDER}/dump"
DESTINATION_ARCHIVE="${DESTINATION_FOLDER}".tar.gz

rm -rf "${DESTINATION_FOLDER}"
rm -rf "${DESTINATION_ARCHIVE}"

find_and_copy(){
    mkdir -p "$2"

    find  "${PRIVATIX_APP_FOLDER}" -path "${DESTINATION_FOLDER}" -prune -o -name "$1" -exec \
        cp '{}' "$2" \;
}

get_value(){
    cat "${dappctrl_config}" | \
        python3 -c 'import json,sys;j=json.load(sys.stdin);print(j["DB"]["Conn"]["'$1'"])';
}

get_dappgui_log_path(){
  cat "${settings_json}" | \
        python3 -c 'import json,sys;j=json.load(sys.stdin);print(j["log"]["filePath"]+"/"+j["log"]["fileName"])';
}

echo "copying files..."
find_and_copy "*.config.json" "${DESTINATION_FOLDER}/configs"
find_and_copy "settings.json" "${DESTINATION_FOLDER}/configs"
find_and_copy "*.log" "${DESTINATION_FOLDER}/logs"
find_and_copy "*.err" "${DESTINATION_FOLDER}/errs"
find_and_copy "*.ovpn" "${DESTINATION_FOLDER}/ovpn"

settings_json=$(find "${DESTINATION_FOLDER}"  -name "settings.json")
dappgui_log_path="$(get_dappgui_log_path | envsubst)"
cp "${dappgui_log_path}" "${DESTINATION_FOLDER}/logs"

dappctrl_config=$(find "${DESTINATION_FOLDER}"  -name "dappctrl.config.json")

echo dumping system data...
mkdir "${DESTINATION_FOLDER}/sysinfo"
systemctl list-units --type=service --state=active > "${DESTINATION_FOLDER}/sysinfo/systemctl.txt"


echo "dumping db..."
find  "${PRIVATIX_APP_FOLDER}" -name "pg_dump" -exec \
   '{}' --create --column-inserts --clean --if-exists \
    -d "$(get_value "dbname")" \
    -h "$(get_value "host")" \
    -p "$(get_value "port")" \
    -U "$(get_value "user")" \
    -f "${DESTINATION_FOLDER}/db_dump.sql" \
     \;

echo "archiving files..."
tar -czf "${DESTINATION_ARCHIVE}" -C "${PRIVATIX_APP_FOLDER}" "dump"
