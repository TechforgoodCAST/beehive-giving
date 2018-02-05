require 'rails_helper'

describe FilterCell do
  before(:each) do
    @filter = cell(:filter, sort: 'eligibility', funding_duration: 12).call(:show)
  end

  it 'has correct options' do
    [
      'Eligibility',
      'Name',
      'All',
      'Eligible',
      'Ineligible',
      'To check',
      'Your proposal',
      'Up to 2 years',
      'More than 2 years'
    ].each do |option|
      expect(@filter).to have_text option
    end
  end

  it 'selected option' do
    expect(@filter).to have_select('sort', selected: 'Eligibility')
  end
end
