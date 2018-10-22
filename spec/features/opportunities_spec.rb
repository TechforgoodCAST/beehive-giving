require 'rails_helper'

feature 'Opportunities' do
  before { @collection = create(:funder_with_funds)}

  scenario 'pick opportunity' do
    visit root_path
    click_link('Opportunities')
    click_link('Get report', match: :first)
    expect(current_path).to eq(new_recipient_path(@collection))
  end

  scenario 'see recent reports' do
    visit opportunities_path
    click_link('Recent reports', match: :first)
    expect(current_path).to eq(opportunities_reports_path(@collection))
  end

  scenario 'add opportunity' do
    visit opportunities_path
    expect(page).to have_link('Add opportunity')
  end

  scenario 'request custom report' do
    visit opportunities_path
    expect(page).to have_link('Request custom report')
  end
end
