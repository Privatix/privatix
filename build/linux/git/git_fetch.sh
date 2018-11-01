#!/usr/bin/env bash

#!/usr/bin/env bash

. ${1}

for repository in ${REPOSITORIES[@]}
do
    echo "${repository}"
    cd "${repository}"
    git fetch origin
done