# Tools

## patch_json.sh

The script replaces values in a json file.

### Usage

```
patch_json.sh <file_name> <replacement1> <replacement2> ... <replacementN> 
```

Where `<replacement>` is a python-like string:

```python
["key"]="value"
```

### Example of usage:

```
./patch_json.sh config.json '["FileLog"]["Level"]="debug"' \
                            '["FileLog"]["File"]="./file.log"'
```

## get_value_json.sh

The script gets values from a json file.

### Usage

```
get_value_json.sh <file_name> <key> 
```

Where `<key>` is a python-like string:

```python
["key"]["sub_key"]
```

### Example of usage:

```
./get_value_json.sh ./config.json '["FileLog"]["Level"]'
```