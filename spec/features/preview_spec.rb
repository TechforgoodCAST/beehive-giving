require 'rails_helper'

feature 'Preview' do
  before(:each) do
    @app.seed_test_db.setup_funds(open_data: true)
    @fund = Fund.first
  end

  scenario 'fund with open data' do
    @fund.update(tags: ['with open data'])
    visit preview_path 'with-open-data'
    expect(page).to have_text 'Awarded', count: 3
  end

  scenario 'tag with spaces' do
    @fund.update(tags: ['tag with spaces'])
    visit preview_path 'tag-with-spaces'
    expect(page).to have_text 'tag with spaces'
  end

  scenario 'tag with comma' do
    @fund.update(tags: ['tag with, comma'])
    visit preview_path 'tag-with-comma'
    expect(page).to have_text 'tag with comma'
  end
end
