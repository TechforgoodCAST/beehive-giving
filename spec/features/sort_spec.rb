require 'rails_helper'

feature 'Sort' do
  scenario 'modal', js: true do
    visit funds_path
    select('Name')
    expect(page).to have_current_path(/sort=name/)
  end
end
