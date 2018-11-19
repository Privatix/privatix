import io
import json
import re
import sys

from sortedcontainers import SortedDict

# pip install -r requirements.txt
_pattern = '^([\w\.]+)=(.*)$'

if len(sys.argv) < 3:
    print('Usage: lng_json.py <source> <dest> [<sorted_dest> [<encoding>]]\n\n'
          'Example:\n'
          'python lng_json.py ./en.lng ./en.json ./en_sorted.lng utf-8\n\n')
    exit(1)


def get_or_default(array, index, default):
    return array[index] if index < len(array) else default


def read_to_sorted_dic(source, encoding):
    sorted_dic = SortedDict()

    with io.open(source, 'r', encoding=encoding) as file:
        for line in file.readlines():
            search_result = re.search(_pattern, line)
            if not search_result:
                continue

            key = search_result.group(1)
            value = search_result.group(2)

            if key in sorted_dic:
                print("A duplicate has been found:\n\t{0} = {2} -> {1}".format(key, value, sorted_dic[key]))

            sorted_dic[key] = value

    return sorted_dic


def write_to_json(dic, dest, encoding):
    with io.open(dest, 'w', encoding=encoding) as file:
        file.write(json.dumps(dic))


def write_to_lng(dic, dest, encoding):
    with io.open(dest, 'w', encoding=encoding) as file:
        for key in dic:
            file.write("{0}={1}\n".format(key, dic[key]))


_encoding = get_or_default(sys.argv, 4, 'utf-8')

_dic = read_to_sorted_dic(sys.argv[1], _encoding)
write_to_json(_dic, sys.argv[2], _encoding)

_sorted_dest = get_or_default(sys.argv, 3, None)
if _sorted_dest:
    write_to_lng(_dic, _sorted_dest, _encoding)
