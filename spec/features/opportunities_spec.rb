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
    find("a[href='#{opportunity_path(@collection)}']").click
    expect(current_path).to eq(opportunity_path(@collection))
  end

  scenario 'add opportunity' do
    visit opportunities_path
    expect(page).to have_link('Add opportunity')
  end

  scenario 'request custom report' do
    visit opportunities_path
    expect(page).to have_link('Request custom report')
  end

  context 'private report' do
    before do
      create(:proposal, collection: @collection, private: Time.zone.now)
      visit opportunity_path(@collection)
    end

    scenario('name') { expect(page).to have_text('Private report') }

    scenario 'private proposal name' do
      within('.p20.flex.flex-column.f1') do
        opts = { text: 'Proposal', class: 'night h6 bold mb5' }
        expect(page).not_to have_selector('div', opts)
      end
    end

    scenario 'private recipient name' do
      msg = 'A charitable organisation - Charity registered in England & Wales'
      expect(page).to have_text(msg)
    end
  end
end
