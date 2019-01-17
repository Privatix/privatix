# Gather logs on Windows
Gather logs, config, DB dump and other info that should assist in troubleshouting on Windows
## DESCRIPTION
* Gather logs, config and DB dump on Windows. 
* Creates folder "dump" inside installation dicretory and places all logs, configs and DB dump in it. 
* Creates zip archive.


## Usage
    
    .\new-dump.ps1

for default installation directory "C:\Program Files\Privatix"

### installDir

Root application folder. E.g. "C:\Program Files\Privatix"

### noComputerLogs

Do not gather additional info about system and network


### With OS info
    
    .\new-dump.ps1 -installDir "C:\Program Files\Privatix"

#### Description
    
Gathers logs, configs and DB dump. Creates folder "dump" inside installation directory and places zipped files in single archive.

### Without OS info
    .\new-dump.ps1 -installDir "C:\Program Files\Privatix" -noComputerLogs

#### Description

Same as above, but do not creates folder "computerLogs" and gather ip, route, adapter, processes, service and OS info. Only application info.

