#!/usr/bin/env bash

#!/usr/bin/env bash

if (( "$#" > 1 ));
then
    echo usage: check_agent_mac.sh [privatix_app_folder_path]
    exit 1
fi

PRIVATIX_APP_FOLDER=${1:-/opt/Privatix}


agent_checker=$(find "${PRIVATIX_APP_FOLDER}"  -name "agent-checker") | head -n 1
${agent_checker}