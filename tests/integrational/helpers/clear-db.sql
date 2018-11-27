--Delete all accounts and previously set passwords.
--(this is required by )
DELETE FROM accounts;
DELETE FROM settings WHERE key='system.password';
DELETE FROM settings WHERE key='system.salt';

--Delete all created offerings.
--(this is required by "Offering popup" tests)
DELETE FROM offerings;
