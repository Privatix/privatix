# .lng—.json converter

## Installation

```bash
pip install -r requirements.txt
```

## Scripts

### lng_json.py

This script convert `*.lng` file to `*.json` file.

```
Usage: lng_json.py <source> <dest> [<sorted_dest> [<encoding>]]

Example:          
    python lng_json.py ./en.lng ./en.json ./en_sorted.lng utf-8
```

If `<sorted_dest>` argument is specified, the script sorts data from the source 
alphabetically, and write sorted data to `<sorted_dest>`.

#### lng file example

`*.lng` file is the key-value text file:

```
Installer.Welcome.Title=Setup - %1$s
Installer.Setup.Title=Setup
Installer.Uninstall.Title=Setup
Installer.Button.Back=< &Back
Installer.Button.Next=&Next >
Installer.Button.Install=&Install
Installer.Button.OK=OK
```

### json_lng.py

This script convert `*.json` file to `*.lng` file.

```
Usage: json_lng.py <source> <dest> [<encoding>]

Example:          
    python json_lng.py ./en.json ./en.lng utf-8
```