require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Beehive
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.exceptions_app = routes

    # controller assets
    config.assets.precompile += %w(
      accounts.css
      eligibilities.css
      enquiries.css
      errors.css
      feedback.css
      funders.css
      funds.css
      organisations.css
      pages.css
      password_resets.css
      profiles.css
      proposals.css
      recipients.css
      signup.css
      sessions.css
    )
    config.assets.precompile += %w(
      accounts.js
      eligibilities.js
      enquiries.js
      errors.js
      feedback.js
      funders.js
      funds.js
      map.js
      organisations.js
      pages.js
      password_resets.js
      profiles.js
      proposals.js
      recipients.js
      signup.js
      sessions.js
    )

    # vendor assets
    config.assets.precompile += %w(
      chosen.css
      overrides/chosen_overrides.css
      overrides/morris_overrides.css
    )
    config.assets.precompile += %w(
      chosen.js
      chosen-jquery.js
      jquery.tree-multiselect.min.js
      morris.js
      raphael.js
    )
  end
end
