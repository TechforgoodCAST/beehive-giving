require 'rails_helper'

feature 'Legacy' do
  include ShowMeTheCookies

  let(:organisation_type) { 'Recipient' }
  let(:user) { create(:user, organisation_type: organisation_type) }

  before do
    create_cookie(:auth_token, user.auth_token)
    visit root_path
  end

  context 'funder' do
    let(:organisation_type) { 'Funder' }
    it { expect(current_path).to eq(legacy_funder_path) }
  end

  scenario 'fundraiser without recipient' do
    expect(current_path).to eq(legacy_fundraiser_path)
  end

  scenario 'fundraiser without proposal' do
    expect(current_path).to eq(legacy_fundraiser_path)
  end
end
