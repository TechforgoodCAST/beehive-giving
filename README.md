# Beehive Giving

[![CircleCI](https://circleci.com/gh/TechforgoodCAST/beehive-giving.svg?style=svg&circle-token=9943df0487898ea0014071a42ee8da8b0d4b1d7e)](https://circleci.com/gh/TechforgoodCAST/beehive-giving)

## Setup
Prerequisites: [Ruby](https://www.ruby-lang.org), [Bundler](https://bundler.io/), [PostgreSQL](https://www.postgresql.org/), [NodeJS](https://nodejs.org/), [Yarn](https://yarnpkg.com/)

1. `bundle install`
2. `yarn`
3. `rails db:setup`
4. Create `.env` file with appropriate configuration:
   ```
   BEEHIVE_DATA_TOKEN=<token>
   BEEHIVE_DATA_FUND_SUMMARY_ENDPOINT=<beehive_data_server>/v1/integrations/fund_summary

   BEEHIVE_INSIGHT_ENDPOINT=<beehive_data_server>/insight/beneficiaries
   BEEHIVE_INSIGHT_AMOUNTS_ENDPOINT=<beehive_data_server>/insight/amounts
   BEEHIVE_INSIGHT_DURATIONS_ENDPOINT=<beehive_data_server>/insight/durations

   STRIPE_SECRET_KEY=<secret_key>
   STRIPE_PUBLISHABLE_KEY=<publishable_key>

   # (optional if needed)
   DATABASE_URL=postgres://username:password@localhost/beehive-data_development
   DATABASE_URL_TEST=postgres://username:password@localhost/beehive-data_test
   ```
5. `rails s` and `bin/webpack-dev-server` to start local development servers

## Importing data
`pg_restore -c -O -d beehive_development <path_to_local_dump_file>`

## Running tests
Use `rspec` to run tests or use [Guard](https://github.com/guard/guard) to run tests automatically whilst developing with `bundle exec guard`.

Use `yarn test` to run Javascript unit tests.
