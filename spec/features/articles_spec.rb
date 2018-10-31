require 'rails_helper'

feature 'Article' do
  before(:each) do
    @articles = create_list(:article, 2)
    @article = @articles.first
    visit root_path
  end

  scenario 'index' do
    click_link 'Blog'
    @articles.each do |article|
      expect(page).to have_content(article.title)
    end
    expect(page).to have_css('.markdown', count: 2)
  end

  scenario 'show' do
    click_link 'Blog'
    click_link @article.title
    expect(page).to have_content(@article.title)
    expect(page).to have_css('.markdown', count: 1)
  end

  scenario 'missing article' do
    visit article_path('missing')
    expect(current_path).to eq(articles_path)
  end
end
