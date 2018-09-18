# Beehive Giving

[![CircleCI](https://circleci.com/gh/TechforgoodCAST/beehive-giving.svg?style=svg&circle-token=9943df0487898ea0014071a42ee8da8b0d4b1d7e)](https://circleci.com/gh/TechforgoodCAST/beehive-giving)

## Setup
Prerequisites: [Ruby](https://www.ruby-lang.org), [Bundler](https://bundler.io/), [PostgreSQL](https://www.postgresql.org/), [NodeJS](https://nodejs.org/), [Yarn](https://yarnpkg.com/)

1. `bundle install`
2. `yarn`
3. `rails db:setup`
4. Create `.env` file with appropriate configuration:
   ```
   STRIPE_SECRET_KEY=<secret_key>
   STRIPE_PUBLISHABLE_KEY=<publishable_key>
   <!-- TODO: document stripe env vars -->
   STRIPE_FEE_OPPORTUNITY_SEEKER=80
   STRIPE_AMOUNT_OPPORTUNITY_SEEKER=1999
   ```
5. `rails s` and `bin/webpack-dev-server` to start local development servers

## Importing data
`pg_restore -c -O -d beehive_development <path_to_local_dump_file>`

## Running tests
- `rspec` to run Ruby unit and feature tests.
- `yarn test` to run JavaScript unit tests.
