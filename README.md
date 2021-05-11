# Beehive Giving

> **PLEASE NOTE:** Beehive was retired in September 2020 and replaced by site ([https://techforgoodcast.github.io/beehive-giving/](https://techforgoodcast.github.io/beehive-giving/)) showcasing an analysis of the proposals submitted to Beehive, as well as some background information about the project and key learnings. The source for this site can be found in the [gh_pages](https://github.com/TechforgoodCAST/beehive-giving/tree/gh-pages) branch and the [master](https://github.com/TechforgoodCAST/beehive-giving/tree/master/) branch contains the last version of the tool (before retirement) for archive purposes.

[Beehive](http://www.beehivegiving.org) is a free and open source funding suitability checking tool maintained by [CAST](http://wearecast.org.uk). It uses a funder’s guidelines, priorities and open data to produce a report that helps fund seekers decide where to apply.

The tool has been developed with charitable grant funding in mind, but has the scope to work for other types of opportunities that non-profits may apply for with minimal changes.

## Getting started

These instructions will get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

[Ruby v2.5.3](https://www.ruby-lang.org), [Bundler](https://bundler.io/), [PostgreSQL](https://www.postgresql.org/), [NodeJS](https://nodejs.org/), [Yarn](https://yarnpkg.com/), and a [Stripe](https://stripe.com) account if you'd like to process payments.

### Local setup

1. `git clone https://github.com/TechforgoodCAST/beehive-giving.git`
2. `cd beehive-giving`
3. `bundle install`
4. `yarn install`
5. `rails db:setup`
6. Create `.env` file with the appropriate configuration:
   ```env
   STRIPE_SECRET_KEY=<your test secret key from Stripe>
   STRIPE_PUBLISHABLE_KEY=<your test publishable key from Stripe>
   STRIPE_FEE_OPPORTUNITY_SEEKER=<card processing fee in pence e.g. 80>
   STRIPE_AMOUNT_OPPORTUNITY_SEEKER=<private report cost in pence e.g. 1999>
   <!-- Optional -->
   HASHIDS_SALT=<a secret key for encoding Hashids>
   ```
7. `rails s` to start local development server

### Running tests

- `bundle exec spring rspec` to run Ruby unit and end-to-end tests.
- `yarn test` to run JavaScript unit tests.

### Administration

This project uses [Active Admin](https://activeadmin.info) to provide a simple administration interface for managing records in the database. Visit the `/admin` path with the server running to make use of it, and see Active Admin's [documentation](https://activeadmin.info/documentation.html) for more details.

## Deployment

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/TechforgoodCAST/beehive-giving)

## Contributing

First of all, **thank you** for your help!

Be sure to check out the projects open [issues](https://github.com/TechforgoodCAST/beehive-giving/issues) to see where help is needed - those labeled [good first issue](https://github.com/TechforgoodCAST/beehive-giving/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue%22) can be a good place to start.

### Bugs

If you've spotted a bug please file an [issue](https://github.com/TechforgoodCAST/beehive-giving/issues) and apply the `bug` label. Even better, submit a [pull request](https://github.com/TechforgoodCAST/beehive-giving/pulls) (details below) with a patch.

### Pull requests

If you want a feature added the best way to get it done is to submit a pull request that implements it...

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Implement your changes
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to GitHub (`git push origin my-new-feature`)
6. Create a [pull request](https://github.com/TechforgoodCAST/beehive-giving/compare/develop...my-new-feature) into the [develop](https://github.com/TechforgoodCAST/beehive-giving/tree/develop) branch

Alternatively you can submit an [issue](https://github.com/TechforgoodCAST/beehive-giving/issues) describing the feature.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/TechforgoodCAST/beehive-giving/tags).

## Authors

- **Suraj Vadgama** - [suninthesky](https://github.com/suninthesky)

See also the list of [contributors](https://github.com/TechforgoodCAST/beehive-giving/contributors) who participated in this project.

## License

This project is released under the MIT License - see the [LICENSE.md](LICENSE.md) for details.
