--Delete all accounts and previously set passwords.
--(this is required by )
DELETE FROM settings WHERE key='system.salt';
DELETE FROM settings WHERE key='system.password';
DELETE FROM accounts;
DELETE FROM endpoints;
DELETE FROM sessions;
DELETE FROM channels;
DELETE FROM users;
DELETE FROM offerings;
DELETE FROM eth_txs;
DELETE FROM jobs;
