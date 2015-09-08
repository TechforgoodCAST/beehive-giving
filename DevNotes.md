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
How to have custom paths?
What's a Proc? (eg Proc.new(|o| etc))
How to have a specific action for a missing item in a rails form? (eg. pulling up an email)

TO CHECK OUT: when are password reset emails sent?

What's the unique key of an organisation? Is it the charity number? some independent key?

Which controller should the holding page be in?

How does rails tell which stage in the signup process you're in? Where should I put the redirect to the loader page? (aplpication_controller when you're ensuring user? or what?)

Model validates charity_number and company_number by uniqueness: AND or OR?