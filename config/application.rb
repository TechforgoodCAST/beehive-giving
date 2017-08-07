require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Beehive
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths += Dir[Rails.root.join('lib', 'core_ext', '*.rb')].each { |l| require l }

    config.exceptions_app = routes

    # controller assets
    config.assets.precompile += %w(
      articles.js
      accounts.js
      eligibilities.js
      enquiries.js
      errors.js
      feedback.js
      funds.js
      helpers.js
      organisations.js
      pages.js
      password_resets.js
      proposals.js
      recipients.js
      signup.js
      sessions.js
      signup_proposals.js
      signup_recipients.js
      users.js
      charges.js
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
