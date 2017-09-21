require 'rails_helper'

feature 'Microsite' do
  scenario 'invalid route parameters' do
    [
      microsite_basics_path('invalid'),
      microsite_eligibility_path('invalid'),
      microsite_eligibility_path('invalid', double('Assessment', id: 1))
    ].each do |path|
      visit path
      expect(current_path).to eq root_path
    end
  end

  scenario 'signed in' do
    expect(current_path).to eq microsite_basics_path('funder')
  end

  scenario 'existing recipient' do
    expect(microsite.assessment.recipient).to eq existing_recipient
  end

  scenario 'assessment per funder' do
    expect(funder1.assessments.size).to eq 1
    expect(funder2.assessments.size).to eq 1
  end

  scenario 'new assessment and proposal per unique request' do
    expect(recipient.assessments.size).to eq 2
  end
end
