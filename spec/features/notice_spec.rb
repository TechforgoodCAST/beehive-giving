require 'rails_helper'

feature 'Notice' do
  include SignInHelper

  let(:user) { create(:user_with_password) }

  scenario 'hidden if logged out' do
    visit root_path
    expect(page).not_to have_link('Got it')
  end

  context 'logged in' do
    before { sign_in(user) }

    scenario 'hidden if update version correct' do
      user.update(update_version: UPDATE_VERSION)
      visit root_path
      expect(page).not_to have_link('Got it')
    end

    scenario 'visible if update version incorrect' do
      visit root_path
      expect(page).to have_link('Got it')
    end
  end
end
