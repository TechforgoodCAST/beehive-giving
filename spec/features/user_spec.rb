require 'rails_helper'

feature 'User' do
  # TODO: refactor
  before do
    @app.seed_test_db
        .create_recipient
        .with_user
        .create_registered_proposal
        .sign_in
  end

  it 'can agree to new terms' do
    visit funds_path
    click_link('Agree')
    expect(page).not_to have_text('Your rights')
  end

  it 'already agreed to new terms' do
    User.last.update_column(:terms_version, TERMS_VERSION)
    visit funds_path
    expect(page).not_to have_text('Your rights')
  end
end
