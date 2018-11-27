import io
import json
import sys

if len(sys.argv) < 3:
    print('Usage: json_lng.py <source> <dest> [<encoding>]\n\n'
          'Example:\n'
          'python json_lng.py ./en.json ./en.lng utf-8\n\n')
    exit(1)


def get_or_default(array, index, default):
    return array[index] if index < len(array) else default


_encoding = get_or_default(sys.argv, 3, 'utf-8')

with io.open(sys.argv[1], 'r', encoding=_encoding) as file:
    _dic = json.load(file)

with io.open(sys.argv[2], 'w', encoding=_encoding) as file:
    for key in sorted(_dic.keys()):
        file.write("{0}={1}\n".format(key, _dic[key]))