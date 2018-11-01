#!/usr/bin/env bash

#!/usr/bin/env bash

. ${1}

for repository in ${ALL_REPOSITORIES[@]}
do
    cd ${repository}
    git fetch origin
done