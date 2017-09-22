require 'rails_helper'

describe Funder do
  before(:all) do
    @funder = create(:funder, name: 'Funder Name')
  end

  it 'has many Users' do
    create_list(:user, 2, organisation: @funder)
    expect(@funder.users.size).to eq 2
  end

  it 'has many Assessments' do
    expect(Funder.reflect_on_association(:assessments).macro).to eq :has_many
  end

  it 'has many Restrictions' do
    expect(Funder.reflect_on_association(:restrictions).macro).to eq :has_many
  end

  it 'has many Funds' do
    build_list(:fund, 2, funder: @funder).each do |fund|
      fund.save(validate: false)
    end
    expect(@funder.funds.size).to eq 2
  end

  it 'has slug' do
    expect(@funder.slug).to eq 'funder-name'
  end

  it 'slug is unique' do
    expect(create(:funder, name: 'Funder Name').slug).to eq 'funder-name-2'
  end

  it 'website invalid' do
    @funder.website = 'www.example.com'
    expect(@funder).not_to be_valid
  end

  it 'website valid' do
    @funder.website = 'https://www.example.com'
    expect(@funder).to be_valid
  end

  it 'is valid' do
    expect(@funder).to be_valid
  end
end
