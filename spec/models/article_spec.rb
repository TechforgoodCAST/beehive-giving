require 'rails_helper'

describe Article do
  before(:each) do
    @articles = create_list(:article, 3)
    @article = @articles.first
  end

  it 'is valid' do
    expect(@article).to be_valid
  end

  it 'requires title' do
    @article.title = ''
    expect(@article).not_to be_valid
  end

  it 'titleize title' do
    @article.title = 'titleize'
    expect(@article.title).to eq 'Titleize'
  end

  it 'requires slug' do
    @article.slug = ''
    expect(@article).not_to be_valid
  end

  it 'slug is unique' do
    @article.slug = @articles[1].slug
    expect(@article).not_to be_valid
  end

  it 'requires body' do
    @article.body = ''
    expect(@article).not_to be_valid
  end

  it '#body_html returns html' do
    html = '<h2><a href="http://www.beehivegiving.org" target="_blank">' \
           "www.beehivegiving.org</a></h2>\n"
    expect(@article.body_html).to eq html
  end
end
