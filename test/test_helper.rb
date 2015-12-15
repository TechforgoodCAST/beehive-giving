ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include FactoryGirl::Syntax::Methods
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  fixtures :all
  include FactoryGirl::Syntax::Methods
  include Capybara::DSL
  include ShowMeTheCookies

  # # Selenium testing
  # Capybara.app_host = "http://localhost:4000"
  # Capybara.server_host = "localhost"
  # Capybara.server_port = "4000"
  # self.use_transactional_fixtures = false

  setup do
    expire_cookies
  end

  def create_and_auth_user!(opts = {})
    @user = create(:user, opts)
    create_cookie(:auth_token, @user.auth_token)
    @recipient.initial_recommendation if @recipient.present?
  end

  def setup_funders(num)
    @funders = Array.new(num) { |i| create(:funder) }
    @grants = Array.new(num) { |i| create(:grants, funder: @funders[i], recipient: @recipient) }
    @attributes = Array.new(num) { |i| create(:funder_attribute, funder: @funders[i]) }
    @restrictions = Array.new(3) { |i| create(:restriction) }
    @funding_streams = Array.new(num) { |i| create(:funding_stream, restrictions: @restrictions, funders: [@funders[i]]) }
    create_and_auth_user!(organisation: @recipient, user_email: 'email@email.com')
    @recipient.refined_recommendation
  end
end
