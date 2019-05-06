#!/usr/bin/env bash

json_path=$1
shift
for i
do json_assignment+=j${i}$'\n'
done

python -c 'import json, sys
with open(sys.argv[1], "r") as f:
    j = json.load(f)
'"$json_assignment"'
with open(sys.argv[1], "w") as f:
   json.dump(j, f)' \
   "$json_path" || exit 1