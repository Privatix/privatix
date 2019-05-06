# Tools

## patch_json.sh

The script replaces values in a json file.

## Usage

```
patch_json.sh <file_name> <replacement1> <replacement2> ... <replacementN> 
```

Where `<replacement>` is a python string like

```python
j["key"]="value"
```

### Example of usage:

```
./patch_json.sh config.json 'j["FileLog"]["Level"]="debug"' \
                            'j["FileLog"]["File"]="./file.log"'
```

