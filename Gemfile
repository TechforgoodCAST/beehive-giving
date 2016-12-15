source 'https://rubygems.org'

ruby '2.3.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem 'rails', '4.2.1'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

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

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'guard-rspec', require: false
  gem 'rspec-rails'
  gem 'stripe-ruby-mock', require: 'stripe_mock'
  gem 'thor', '0.19.1' # TODO: guard dependency
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'bullet'
  gem 'meta_request'
  gem 'pry'
  gem 'pry-rails'
  gem 'rubocop', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :test do
  gem 'capybara'
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'show_me_the_cookies'
  gem 'webmock'
end

gem 'acts-as-taggable-on', '~> 4.0'
gem 'chartkick'
gem 'chosen-rails'
gem 'country_select'
gem 'geocoder'
gem 'gon'
gem 'groupdate'
gem 'haml'
gem 'httparty'
gem 'jquery-turbolinks'
gem 'nokogiri'
gem 'nprogress-rails'
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
gem 'newrelic_rpm'
gem 'rollbar'
group :production do
  gem 'rails_12factor'
  gem 'scout_apm'
  gem 'tunemygc'
end
