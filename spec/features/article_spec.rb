require 'rails_helper'

feature 'Article' do
  before(:each) do
    @articles = create_list(:article, 3)
    @article = @articles.first
    visit root_path
  end

  scenario 'index' do
    click_link 'Articles'
    @articles.each do |article|
      expect(page).to have_content article.title
    end
    expect(page).to have_css '.markdown', count: 3
    expect(page).to have_link 'Sign up free today'
  end

  scenario 'show' do
    click_link 'Articles'
    click_link @article.title
    expect(page).to have_link 'Back to articles'
    expect(page).to have_link 'Sign up free today'
    expect(page).to have_content @article.title
    expect(page).to have_css '.markdown', count: 1
  end
end
