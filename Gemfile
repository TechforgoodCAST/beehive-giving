source 'https://rubygems.org'

ruby '2.5.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'activerecord-import'
gem 'cells-rails' # TODO: remove
gem 'cells-slim' # TODO: remove
gem 'chartkick'
gem 'groupdate'
gem 'hamlit'
gem 'hashids'
gem 'kaminari'
gem 'pundit'
gem 'rack-tracker'
gem 'redcarpet'
gem 'simple_form'
gem 'sitemap_generator'
gem 'stripe'
gem 'xxhash'

# Admin
gem 'activeadmin'
gem 'devise'

# Monitoring & metrics
gem 'intercom-rails' # TODO: review
gem 'rollbar'
group :production do
  gem 'rails_12factor'
  gem 'scout_apm'
  gem 'tunemygc'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'capybara'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'rspec-cells' # TODO: remove
  gem 'rspec-rails', '3.5.2'
  gem 'selenium-webdriver'
  gem 'stripe-ruby-mock', require: 'stripe_mock'
  gem 'webmock'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'bullet'
  gem 'meta_request'
  gem 'pry'
  gem 'pry-rails'
  gem 'rubocop', require: false
  gem 'yard'
end

group :test do
  gem 'climate_control'
  gem 'database_cleaner'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
