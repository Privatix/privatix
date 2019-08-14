cat "${1}" | \
        python -c 'import json,sys;j=json.load(sys.stdin);print(j'"${2}"')';

