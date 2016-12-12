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
      sessions.css
      pages.css
      signup.css
      organisations.css
      profiles.css
      funders.css
      recipients.css
      feedback.css
      password_resets.css
      proposals.css
      accounts.css
      funds.css
      eligibilities.css
      enquiries.css
    )
    config.assets.precompile += %w(
      sessions.js
      pages.js
      signup.js
      organisations.js
      profiles.js
      funders.js
      recipients.js
      feedback.js
      password_resets.js
      proposals.js
      map.js
      accounts.js
      funds.js
      eligibilities.js
      enquiries.js
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
      morris.js
      raphael.js
      jquery.tree-multiselect.min.js
    )
  end
end
