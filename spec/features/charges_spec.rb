require 'rails_helper'
require 'stripe_mock'

feature 'Charges' do
  let(:proposal) { create(:proposal) }

  scenario 'report already private' do
    proposal.update_column(:private, Time.zone.now)
    visit new_charge_path(proposal)
    expect(current_path).to eq(sign_in_lookup_path)
  end

  scenario 'proposal missing' do
    visit new_charge_path('missing')
    expect(page.status_code).to eq(404)
    expect(page).to have_text('Not found')
  end

end
