#!/usr/bin/env bash

if (( "$#" > 1 ));
then
    echo usage: dump_mac.sh [privatix_app_folder_path]
    exit 1
fi

PRIVATIX_APP_FOLDER=${1:-/Applications/Privatix}

DESTINATION_FOLDER="${PRIVATIX_APP_FOLDER}/dump"
DESTINATION_ARCHIVE="${DESTINATION_FOLDER}".zip

rm -rf "${DESTINATION_FOLDER}"
rm -rf "${DESTINATION_ARCHIVE}"

find_and_copy(){
    mkdir -p "$2"

    find  "${PRIVATIX_APP_FOLDER}" -path "${DESTINATION_FOLDER}" -prune -o -name "$1" -exec \
        cp '{}' "$2" \;
}

get_value(){
    cat "${dappctrl_config}" | \
        python -c 'import json,sys;j=json.load(sys.stdin);print j["DB"]["Conn"]["'$1'"]';
}


echo "copying files..."
find_and_copy "*.config.json" "${DESTINATION_FOLDER}/configs"
find_and_copy "settings.json" "${DESTINATION_FOLDER}/configs"
find_and_copy "*.log" "${DESTINATION_FOLDER}/logs"
find_and_copy "*.err" "${DESTINATION_FOLDER}/errs"
find_and_copy "*.ovpn" "${DESTINATION_FOLDER}/ovpn"

echo "getting dappctrl version..."
find "${PRIVATIX_APP_FOLDER}" -name "dappctrl" -exec \
   '{}' --version \; 2>/dev/null > "${DESTINATION_FOLDER}/dappctrl_version.txt"

echo "executing commands..."
networksetup -getsocksfirewallproxy Wi-Fi > "${DESTINATION_FOLDER}/wifi.txt"
networksetup -getsocksfirewallproxy Ethernet > "${DESTINATION_FOLDER}/ethernet.txt"

dappctrl_config=$(find "${DESTINATION_FOLDER}"  -name "dappctrl.config.json")

echo dumping system data...
mkdir "${DESTINATION_FOLDER}/sysinfo"
launchctl list | grep privatix > "${DESTINATION_FOLDER}/sysinfo/launchctl.txt"

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
zip -r "${DESTINATION_ARCHIVE}" "${DESTINATION_FOLDER}"