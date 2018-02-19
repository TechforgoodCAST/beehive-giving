require 'rails_helper'

describe FilterCell do
  let(:funding_duration) { 12 }
  let(:filter) do
    cell(
      :filter,
      { eligibility: 'eligible' },
      funding_duration: funding_duration
    ).call(:show)
  end

  it 'has correct options' do
    [
      'All',
      'Eligible',
      'Ineligible',
      'To check',
      'Your proposal',
      'Up to 2 years',
      'More than 2 years'
    ].each do |option|
      expect(filter).to have_text(option)
    end
  end

  context 'funding_duration missing' do
    let(:funding_duration) { nil }

    it 'hides proposal duration option' do
      expect(filter).not_to have_text('Your proposal')
    end
  end

  it 'selected option' do
    expect(filter).to have_select('eligibility', selected: 'Eligible')
  end
end
