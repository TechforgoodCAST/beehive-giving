require 'rails_helper'

feature 'Privacy' do
  include SignInHelper

  let(:user) { create(:user_with_password) }

  it 'can agree to new terms' do
    sign_in(user)
    visit reports_path
    click_link('Agree')
    expect(page).not_to have_text('Your rights')
  end
end
