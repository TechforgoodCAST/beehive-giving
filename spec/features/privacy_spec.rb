require 'rails_helper'

feature 'Privacy' do
  include ShowMeTheCookies

  let(:user) { create(:registered_user) }

  before { create_cookie(:auth_token, user.auth_token) }

  it 'can agree to new terms' do
    visit funds_path
    click_link('Agree')
    expect(page).not_to have_text('Your rights')
  end
end
