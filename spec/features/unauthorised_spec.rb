require 'rails_helper'
require_relative '../support/match_helper'
require_relative '../support/signup_helper'

feature 'Unauthorised' do
  let(:form) { SignupHelper.new }
  let(:helper) { MatchHelper.new }
  let(:recipient) do
    create(:recipient, charity_number: '1161998', company_number: '09544506')
  end
  let(:user) { create(:user, organisation: recipient) }

  before(:each) do
    helper.stub_charity_commission.stub_companies_house
    create(:admin_user)
  end

  scenario 'when recipient already registerd' do
    create(:theme, id: 1, name: 'Theme1')
    create(:country, districts: [create(:district)])
    recipient

    visit root_path

    select 'Capital funding'
    select 'A registered charity'
    fill_in :signup_basics_charity_number, with: '1161998'
    select 'United Kingdom', match: :first
    select 'Theme1'
    click_button 'Find suitable funds'

    form.complete_signup_suitability_form

    expect(current_path).to eq(unauthorised_path)
    expect(User.count).to eq(1)
  end

  context do
    before(:each) do
      user.lock_access_to_organisation(recipient)
      visit grant_access_path(user.unlock_token)
    end

    scenario 'grant access' do
      expect(current_path).to eq(granted_access_path(user.unlock_token))
    end

    scenario 'grant access triggers email' do
      subject = 'You have been granted access to your organisation'
      expect(ActionMailer::Base.deliveries.last.subject).to eq(subject)
    end
  end
end
