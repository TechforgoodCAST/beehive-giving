require 'rails_helper'

feature 'Notice' do
  include SignInHelper

  let(:user) { create(:user_with_password) }

  it 'hidden if logged out' do
    visit root_path
    expect(page).not_to have_link('Got it')
  end

  context 'logged in' do
    before { sign_in(user) }

    it 'hidden if update version correct' do
      user.update(update_version: UPDATE_VERSION)
      visit root_path
      expect(page).not_to have_link('Got it')
    end

    it 'visible if update version incorrect' do
      visit root_path
      expect(page).to have_link('Got it')
    end
  end
end
