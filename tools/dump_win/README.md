# Gather logs on Windows
Gather logs, config and DB dump on Windows
## DESCRIPTION
* Gather logs, config and DB dump on Windows. 
* Cretaes folder "dump" inside installation dicretory and places all logs, configs and DB dump in it. 
* Creates zip archive.


## Usage
    
    .\new-dump.ps1 -installDir "C:\build\1205_1836\client\" -computerLogs

### installDir

Root application folder. E.g. "C:\Program Files\Privatix\Agent"

### computerLogs

Gather additional info about computer and network


### Without OS info
    
    .\new-dump.ps1 -installDir "C:\build\1205_1836\Client\"

#### Description
    
Gathers logs, configs and DB dump. Creates folder "dump" inside installation directory and places zipped files in single archive.

### With OS info
    .\new-dump.ps1 -installDir "C:\build\1205_1836\client\" -computerLogs

#### Description

Same as above, but also creates folder "computerLogs" and gather ip, route, adapter, processes, service and OS info.

