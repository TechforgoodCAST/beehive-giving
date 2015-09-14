## DEVELOPER NOTES
==============

- Running postgres server on local computer: 
pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start

- Loading database:
pg_restore --clean -O -d beehive_development beehive_backup_15.08.15.dump

- Viewing database:
Rachels-MacBook-Pro-2:beehive Rachel$ psql -h localhost -U postgres
psql: FATAL:  role "postgres" does not exist
Rachels-MacBook-Pro-2:beehive Rachel$ createuser -s -r postgres

### QUESTIONS
=========

HTTP verb for authorisation? (GET vs PUT vs PATCH?)
Where to put grant_access & access_granted function? 
  - in Recipients controller? 
Bulk authorise?