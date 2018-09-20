require 'rails_helper'
require 'stripe_mock'

feature 'Charges' do
  let(:proposal) { create(:proposal) }

  scenario 'report already private' do
    proposal.update_column(:private, Time.zone.now)
    visit new_charge_path(proposal)
    expect(current_path).to eq(report_path(proposal))
  end

  scenario 'proposal missing' do
    visit new_charge_path('missing')
    expect(page.status_code).to eq(404)
    expect(page).to have_text('Not found')
  end

  scenario 'skips payment' do
    visit new_charge_path(proposal)
    click_link('free public report')
    expect(current_path).to eq(report_path(proposal))
  end

  context do
    let(:stripe) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }

    scenario 'can make report private' do
      visit new_charge_path(proposal)
      pay_by_card(stripe)

      proposal.reload
      path = report_path(proposal, t: proposal.access_token)

      expect(proposal.private?).to eq(true)
      expect(page).to have_current_path(path)
    end

    scenario 'card error' do
      {
        card_declined:    'The card was declined',
        incorrect_cvc:    "The card's security code is incorrect",
        expired_card:     'The card has expired',
        processing_error: 'An error occurred while processing the card',
        incorrect_number: 'The card number is incorrect'
      }.each do |state, msg|
        StripeMock.prepare_card_error(state, :new_customer)
        visit new_charge_path(proposal)
        pay_by_card(stripe)

        expect(page).to have_text(msg)
      end
    end
  end

  def pay_by_card(stripe)
    fill_in('card-number', with: '4242 4242 4242 4242')
    fill_in('expiry-month', with: '01')
    fill_in('expiry-year', with: Time.zone.today.year + 1)
    fill_in('cvc', with: '123')
    find('#stripeToken', visible: false).set(stripe.generate_card_token)
    click_on('Purchase private report')
  end
end
