require 'rails_helper'

feature 'Sidebar' do
  def expect_query(link, query_string)
    visit funds_path
    click_link(link)
    expect(page).to have_current_path(/\?#{query_string}/)
  end

  scenario { expect_query('Revealed', 'revealed=true') }

  scenario { expect_query('Incomplete', 'eligibility=to-check') }

  scenario { expect_query('Eligible', 'eligibility=eligible') }

  scenario { expect_query('Ineligible', 'eligibility=ineligible') }

  context do
    before { @theme = create(:theme) }

    scenario do
      visit funds_path
      expect(page).to have_text(@theme.name, count: 2)

      click_link(@theme.name)
      expect(current_path).to eq(theme_path(@theme))
    end
  end
end
