require 'rails_helper'
require_relative '../support/match_helper'

feature 'Match' do

  let(:helper) { MatchHelper.new }

  before(:each) do
    @app.seed_test_db.setup_funds(num: 3, open_data: true)
    @db = @app.instances
    helper.stub_charity_commission.stub_companies_house
    visit signup_user_path
  end

  scenario "When I attempt to sign up as an individual,
            I want to be directed to appropriate support,
            so I can avoid wasted effort"

  scenario "When I complete my first funding proposal,
            I want to see a shortlist of the most relevant funds,
            so I feel I've found suitable funding opportunities" do

    helper.submit_user_form # TODO: as charity
    expect(current_path).to eq signup_organisation_path

    {
      org_type: '3',
      charity_number: '1161998',
      company_number: '09544506',
      name: 'Centre For The Acceleration Of Social Technology',
      country: 'GB',
      operating_for: '2',
      website: 'http://www.wearecast.org.uk'
    }.each do |k, v|
      expect(find_field("recipient_#{k}").value).to eq v
    end

    helper.submit_organisation_form
    expect(current_path).to eq new_recipient_proposal_path(Recipient.last)

    helper.submit_proposal_form
    expect(current_path).to eq funds_home_path
    expect(page).to have_css '.funder', count: 3

    expect(page.first('.funder').text).to eq 'Awards for All 3'
  end

  # context 'individual'
  # context 'unregistered'
  # context 'charity'
  # context 'company'
  # context 'charity & company'
  # context 'other org'
  # context 'pre-registered'

end
