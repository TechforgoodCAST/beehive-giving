require 'rails_helper'

feature 'Article' do
  before(:each) do
    @articles = create_list(:article, 3)
    @article = @articles.first
    visit root_path
  end

  scenario 'index' do
    click_link 'Research'
    @articles.each do |article|
      expect(page).to have_content article.title
    end
    expect(page).to have_css '.markdown', count: 3
    expect(page).to have_text 'Ready to get started?'
  end

  scenario 'show' do
    click_link 'Research'
    click_link @article.title
    expect(page).to have_link 'Back to Research'
    expect(page).to have_text 'Ready to get started?'
    expect(page).to have_content @article.title
    expect(page).to have_css '.markdown', count: 1
  end
end
