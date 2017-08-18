require 'rails_helper'

describe FilterCell do
  before(:each) do
    @filter = cell(:filter, sort: 'name', funding_duration: 12).call(:show)
  end

  it 'has correct options' do
    %w[Best Name All Eligible Ineligible Your proposal Up to 2 years].each do |option|
      expect(@filter).to have_text option
    end
  end

  it 'selected option' do
    expect(@filter).to have_select('sort', selected: 'Name')
  end
end
