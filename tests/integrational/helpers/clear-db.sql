DELETE FROM accounts;
DELETE FROM settings WHERE key='system.password';
DELETE FROM settings WHERE key='system.salt';

DELETE FROM offerings;
