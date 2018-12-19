require 'rails_helper'

feature 'Cookies' do
  include SignInHelper

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
    visit root_path
    browser = page.driver.browser.manage
    browser.add_cookie(name: '_beehive_session', value: 'value')
    browser.add_cookie(name: 'tracker', value: 'value')

    click_link 'Change settings'

    expect(browser.all_cookies.pluck(:name))
      .to contain_exactly('_beehive_session', 'tracker')

    click_link 'Turn Off', match: :first
    sleep(1)
    expect(browser.all_cookies.pluck(:name))
      .to contain_exactly('_beehive_session')
  end

  context do
    let(:user) { create(:user_with_password) }
    before { sign_in(user) }

    scenario 'cookie preferences remembered when signing out' do
      click_link 'Continue'
      expect(page).not_to have_text('Change settings')
      click_link 'Sign out'
      expect(page).not_to have_text('Change settings')
    end
  end
end
