require 'rails_helper'

feature 'Preview' do
  let(:fund) { create(:fund_simple, geo_area: geo_area) }
  let(:geo_area) { build(:geo_area, countries: [build(:country)]) }

  scenario 'redirects to theme_path' do
    theme = fund.themes.first
    visit "/preview/#{theme.slug}"
    expect(current_path).to eq(theme_path(theme))
  end
end
