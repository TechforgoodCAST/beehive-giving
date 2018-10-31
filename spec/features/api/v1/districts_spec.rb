require 'rails_helper'

feature 'Districts API' do
  before { @district = create(:district) }

  scenario 'valid request' do
    visit api_v1_districts_path(@district.country, format: :json)
    body = JSON.parse(page.body)
    expect(body.size).to eq(1)
    body.each do |o|
      expect(o).to have_key('value')
      expect(o).to have_key('label')
    end
  end

  scenario 'invalid request' do
    visit api_v1_districts_path('missing', format: :json)
    expect(JSON.parse(page.body)).to eq([])
  end
end
