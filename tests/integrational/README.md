# Integrational Tests
Privatix integrational tests.

## Tests
There are six test blocks for now.

* Configuration Check
_used to check env.vars required by some tests and config. file data_ 
* Websocket Communication
_connection initialization tests and all other tests blocks that require open websocket connections_
  * Setting Passwords
  * Generating Agent Account
  * Get Test ETH and PRIX
  * Offering Popup


## Helpers
There are two helpers: you can use to set up environment for tests.

#### setenv.sh 
Setting environmental variables required by some tests.

```
# To run:
. ./helpers/setenv.sh
```

Required by:
- **configuration check** test
- **get test ETH and PRIX** test

#### clear-db.sql 
SQL script that deletes from DB accounts, previously set passwords and created offerings.

> It is desirable to run this script before starting tests, because many tests require clean DB.

```
# To run from bash:
psql -U postgres -d dappctrl -a -f ./helpers/clear-db.sql
```
```
# To run from psql:
\c dappctrl
\i ./helpers/clear-db.sql
```
