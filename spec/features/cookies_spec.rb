require 'rails_helper'

feature 'Cookies' do
  include ShowMeTheCookies

  context 'banner' do
    before { visit root_path }

    scenario('visible') { expect(page).to have_text('Change settings') }

    scenario 'continuing hides' do
      click_link 'Continue'
      expect(page).not_to have_text('Change settings')
    end

    scenario 'changing settings hides' do
      click_link 'Change settings'
      expect(page).not_to have_text('Change settings')
    end
  end

  scenario 'can be dectivated', js: true do
    page.driver.set_cookie('_beehive_session', 'value')
    page.driver.set_cookie('tracker', 'value')

    visit funds_path
    click_link 'Change settings'
    expect(page.driver.cookies.keys)
      .to contain_exactly('_beehive_session', 'tracker')

    click_link 'Turn Off', match: :first
    sleep(1)
    expect(page.driver.cookies.keys).to contain_exactly('_beehive_session')
  end
end
