require File.expand_path('../boot', __FILE__)
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Beehive
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.exceptions_app = self.routes

    # controller assets
    config.assets.precompile += %w(
      sessions.css
      pages.css
      signup.css
      organisations.css
      profiles.css
      funders.css
      recipients.css
    )
    config.assets.precompile += %w(
      sessions.js
      pages.js
      signup.js
      organisations.js
      profiles.js
      funders.js
      recipients.js
    )

    # vendor assets
    config.assets.precompile += %w(
      chosen.css
      overrides/chosen_overrides.css
      overrides/morris_overrides.css
      timelineJS/timeline.css
      timelineJS/themes/font/BreeSerif-OpenSans.css
    )
    config.assets.precompile += %w(
      chosen.js
      chosen-jquery.js
      morris.js
      raphael.js
      timelineJS/embed.js
    )
  end
end
