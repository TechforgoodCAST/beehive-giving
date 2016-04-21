ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include FactoryGirl::Syntax::Methods
  Geocoder.configure(:lookup => :test)
  Geocoder::Lookup::Test.add_stub(
    "A1 B2, GB", [{'latitude' => 40.7143528, 'longitude' => -74.0059731}])
  Geocoder::Lookup::Test.add_stub(
    "BS48 3PA, GB", [{'latitude' => 2, 'longitude' => 2}])
  Geocoder::Lookup::Test.add_stub(
    "GL6 0QL, GB", [{'latitude' => 1, 'longitude' => 1}])
  Geocoder::Lookup::Test.add_stub(
    "London Road, GB", [{'latitude' => 0, 'longitude' => 0}])
  Geocoder::Lookup::Test.add_stub(
    "SE1 7TP, GB", [{'latitude' => 3, 'longitude' => 3}])
end

class ActionDispatch::IntegrationTest
  # Make the Capybara DSL available in all integration tests
  include FactoryGirl::Syntax::Methods
  include Capybara::DSL
  include ShowMeTheCookies

  # Selenium
  Capybara.app_host = "http://localhost:4000"
  Capybara.server_host = "localhost"
  Capybara.server_port = "4000"

  setup do
    expire_cookies
  end

  def create_and_auth_user!(opts = {})
    @user = create(:user, opts)
    create_cookie(:auth_token, @user.auth_token)
  end

  def setup_funders(num, proposal=false)
    FactoryGirl.create_list(:beneficiary, num)
    FactoryGirl.create_list(:age_group, num)

    FactoryGirl.create_list(:country, num)
    Country.all.each do |c|
      FactoryGirl.create_list(:district, num, country: c)
    end

    @funders = Array.new(num) { |i| create(:funder) }
    @grants = Array.new(num) { |i| create(:grants, funder: @funders[i], recipient: @recipient) }
    @attributes = Array.new(num) { |i| create(:funder_attribute, funder: @funders[i],
                    beneficiaries: Beneficiary.limit(i+1),
                    age_groups: AgeGroup.limit(i+1),
                    countries: Country.limit(i+1),
                    districts: District.where(country: Country.limit(i+1))
                  ) }
    @restrictions = Array.new(3) { |i| create(:restriction) }
    @funding_streams = Array.new(num) { |i| create(:funding_stream, restrictions: @restrictions, funders: [@funders[i]]) }
    create_and_auth_user!(organisation: @recipient, user_email: 'email@email.com')

    @proposal = create(:proposal, recipient: @recipient,
                        beneficiaries: Beneficiary.all,
                        age_groups: AgeGroup.all,
                        countries: Country.all,
                        districts: District.all
                      ) if proposal
  end
end
