<#
.Synopsis
   Initialize dappctrl database
.DESCRIPTION
   Initialize dappctrl database. If existing DB is found it is removed and re-initialized.
.PARAMETER dappctrlconf
    path to dappctrl configuration file (json)
.PARAMETER settingSQL
    path to settings.sql file used to drop/create database
.PARAMETER schemaSQL
    path to schema.sql file used to create database schema
.PARAMETER dataSQL
    path to prod_data.sql file used to insert initial data to database
.PARAMETER psqlpath
    (optional) path to psql.exe file. If not specified, script will try to find it in %PATH
.EXAMPLE
   deploy-dappdb -dappctrlconf c:\dappctrl\dappctrl.config.json -settingSQL c:\dappctrl\data\settings.sql -schemaSQL c:\dappctrl\data\schema.sql -dataSQL c:\dappctrl\data\prod_data.sql
.EXAMPLE
   deploy-dappdb -dappctrlconf c:\dappctrl\dappctrl.config.json -settingSQL c:\dappctrl\data\settings.sql -schemaSQL c:\dappctrl\data\schema.sql -dataSQL c:\dappctrl\data\prod_data.sql -psqlpath c:\pgsql\psql.exe
.EXAMPLE
   deploy-dappdb -dappctrlconf "$($env:GOPATH)\src\github.com\privatix\dappctrl\dappctrl-dev.config.json" -schemaSQL "$($env:GOPATH)\src\github.com\privatix\dappctrl\data\schema.sql" -settingSQL "$($env:GOPATH)\src\github.com\privatix\dappctrl\data\settings.sql" -dataSQL "$($env:GOPATH)\src\github.com\privatix\dappctrl\data\prod_data.sql" -psqlpath "$($env:ProgramW6432)\PostgreSQL\10.4\bin\psql.exe"
#>
function deploy-dappdb {
    [cmdletbinding()]
    Param (
        [ValidateNotNullorEmpty()]
        [ValidateScript( {Test-Path $_})]
        [string]$dappctrlconf,
        [ValidateNotNullorEmpty()]
        [ValidateScript( {Test-Path $_})]
        [string]$settingSQL,
        [ValidateNotNullorEmpty()]
        [ValidateScript( {Test-Path $_})]
        [string]$schemaSQL,
        [ValidateScript( {Test-Path $_})]
        [string]$dataSQL,
        [ValidateScript( {Test-Path $_})]
        [string]$psqlpath,
        [switch]$migrations
    )

    Write-Verbose "Deploying database"

    # import helpers
    import-module (join-path $PSScriptRoot "build-helpers.psm1" -resolve) -DisableNameChecking -ErrorAction Stop -Verbose:$false

    # Check psql.exe existance
    If (!($psqlpath)) {
        $psqlapp = Find-App "psql"
        if ($psqlapp) {
            $psqlver = $psqlapp.Version
            $psqlpath = $psqlapp.Source
        }
        else {throw "psql.exe not found in %PATH"}
        Write-Verbose "psql version: $psqlver"
        Write-Verbose "psql path: $psqlpath"
    }

    # Parse dappctrl config DB section
    Write-Verbose "Parse dappctrl config DB section"
    $DBconf = (Get-Content $dappctrlconf | ConvertFrom-Json).DB.conn 
    if ($DBconf.password) {$env:PGPASSWORD = $DBconf.password}
                
    # Check DB exists
    Write-Verbose "Check DB exists"
    $checkdbexists = "`"SELECT 1 FROM pg_database WHERE datname=`'$($DBconf.dbname)`';`""
    $psqlcmd = "& `'$psqlpath`' -h $($DBconf.host) -p $($DBconf.port) -U $($DBconf.user) -tAc $checkdbexists"
    $dbexists = Invoke-Scriptblock -ScriptBlock $psqlcmd -ThrowOnError
    Write-Verbose "DB $($DBconf.dbname) exists: $dbexists"
    
    if ($dbexists) {
        # Block access to DB
        Write-Verbose "Block access to DB"
        $psqlcmd = "& `'$psqlpath`' -h $($DBconf.host) -p $($DBconf.port) -U $($DBconf.user) -c `"REVOKE CONNECT ON DATABASE $($DBconf.dbname) FROM public;`""
        Invoke-Scriptblock -ScriptBlock $psqlcmd -ThrowOnError

        # Drop all other connections from DB
        Write-Verbose "Drop all other connections from DB"
        $dropDbSessions = "`"SELECT pid, pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = current_database() AND pid <> pg_backend_pid();`""
        $psqlcmd = "& `'$psqlpath`' -h $($DBconf.host) -p $($DBconf.port) -U $($DBconf.user) -d $($DBconf.dbname) -c $dropDbSessions"
        Invoke-Scriptblock -ScriptBlock $psqlcmd -ThrowOnError
    }

    # Create new DB from setting.sql
    Write-Verbose "Create new DB from setting.sql"
    $psqlcmd = "& `'$psqlpath`' -h $($DBconf.host) -p $($DBconf.port) -U $($DBconf.user) -f $settingSQL"
    Invoke-Scriptblock -ScriptBlock $psqlcmd -ThrowOnError

    $connstr = "host=$($DBconf.host) dbname=$($DBconf.dbname) user=$($DBconf.user) port=$($DBconf.port)"
    if ($($DBconf.password)) {$connstr += " password=$($DBconf.password)"}
    $connstr += " sslmode=disable"

    if ($migrations) {
        # Migrations 
        Invoke-Scriptblock "dappctrl db-migrate -conn $connstr"
        Invoke-Scriptblock "dappctrl db-init-data -conn $connstr"
    }
    else {
        # Apply DB schema
        Write-Verbose "Apply DB schema"
        $psqlcmd = "& `'$psqlpath`' -h $($DBconf.host) -p $($DBconf.port) -U $($DBconf.user) -d $($DBconf.dbname) -f $schemaSQL"
        Invoke-Scriptblock -ScriptBlock $psqlcmd -ThrowOnError

        # Apply initial DB data
        Write-Verbose "Apply initial DB data"
        $psqlcmd = "& `'$psqlpath`' -h $($DBconf.host) -p $($DBconf.port) -U $($DBconf.user) -d $($DBconf.dbname) -f $dataSQL"
        Invoke-Scriptblock -ScriptBlock $psqlcmd -ThrowOnError
    }
        
}