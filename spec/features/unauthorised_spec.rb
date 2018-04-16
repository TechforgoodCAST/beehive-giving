require 'rails_helper'
require_relative '../support/match_helper'
require_relative '../support/signup_helper'

feature 'Unauthorised' do
  let(:user) { SignupHelper.new }
  let(:helper) { MatchHelper.new }

  before(:each) do
    helper.stub_charity_commission.stub_companies_house
  end

  scenario 'when recipient already registerd' do
    create(:admin_user)
    create(:theme, id: 1, name: 'Theme1')
    create(:country, districts: [create(:district)])
    create(:recipient, charity_number: '1161998', company_number: '09544506')

    visit root_path

    select 'Capital funding'
    select 'A registered charity'
    fill_in :signup_basics_charity_number, with: '1161998'
    select 'United Kingdom', match: :first
    select 'Theme1'
    click_button 'Find suitable funds'

    user.complete_signup_suitability_form

    expect(current_path).to eq(unauthorised_path)
    expect(User.count).to eq(1)
  end
end
