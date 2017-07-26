source 'https://rubygems.org'

ruby '2.3.3'

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

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Use jquery as the JavaScript library
gem 'jquery-rails'
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
gem 'cells-rails'
gem 'cells-slim'
gem 'chartkick'
gem 'chosen-rails'
gem 'country_select'
gem 'geocoder'
gem 'gon'
gem 'groupdate'
gem 'hamlit' # TODO: replace with gem 'slim'
gem 'httparty'
gem 'kaminari'
gem 'nokogiri'
gem 'redcarpet'
gem 'simple_form'
gem 'stripe'
gem 'uikit-sass-rails'
gem 'workflow'

# Admin
gem 'activeadmin', git: 'https://github.com/activeadmin/activeadmin'
gem 'devise'
gem 'inherited_resources', git: 'https://github.com/activeadmin/inherited_resources'

# Monitoring & metrics
gem 'intercom-rails'
gem 'rollbar'
group :production do
  gem 'rails_12factor'
  gem 'scout_apm'
  gem 'tunemygc'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '2.12.1'
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'rspec-cells'
  gem 'rspec-rails', '3.5.2'
  gem 'selenium-webdriver'
  gem 'show_me_the_cookies'
  gem 'stripe-ruby-mock', require: 'stripe_mock'
  gem 'webmock'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'bullet'
  gem 'meta_request'
  gem 'pry'
  gem 'pry-rails'
  gem 'rubocop', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'poltergeist'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
