require 'rails_helper'

feature 'Filter' do
  scenario 'modal', js: true do
    visit funds_path
    find('.js-show-modal').click
    select('Eligible')
    click_button('Filter')
    expect(page).to have_current_path(/\?eligibility=eligible&duration=all/)
  end

  scenario 'keeps original url', js: true do
    visit funds_path(123)
    find('.js-show-modal').click
    select('Eligible')
    click_button('Filter')
    expect(page).to have_current_path(/\123?eligibility/)
  end
end
