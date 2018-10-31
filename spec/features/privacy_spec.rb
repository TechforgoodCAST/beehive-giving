require 'rails_helper'

feature 'Privacy' do
  include SignInHelper

  let(:user) { create(:user_with_password) }

  scenario 'can agree to new terms' do
    sign_in(user)
    visit reports_path
    click_link('Agree')
    expect(page).not_to have_text("We've updated our privacy policy.")
  end

  scenario 'terms agreement up to date' do
    user.update!(terms_version: TERMS_VERSION)
    visit reports_path
    expect(page).not_to have_text("We've updated our privacy policy.")
  end
end
