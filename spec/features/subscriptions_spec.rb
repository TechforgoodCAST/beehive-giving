require 'rails_helper'
require_relative '../support/subscriptions_helper'
require 'stripe_mock'

feature 'Subscriptions' do
  let(:helper) { SubscriptionsHelper.new }
  let(:stripe) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  context 'signed in' do
    before(:each) do
      @app.seed_test_db
          .create_recipient
          .with_user
          .create_complete_proposal
          .sign_in
      @db = @app.instances
    end

    scenario 'notice not shown from account_subscription_path' do
      visit account_subscription_path(@db[:recipient])
      click_link 'Upgrade'
      expect(page).not_to have_text 'Please upgrade to access this feature.'
    end

    scenario 'return_to request.referer if available' do
      visit proposals_path
      click_link 'New proposal'
      helper.pay_by_card(stripe)
      click_link 'Continue'
      expect(current_path).to eq proposals_path
    end

    scenario 'plan/price set by recipient.income_band' do
      (0..3).each do |income_band|
        @db[:recipient].update(income_band: income_band)
        payment = Payment.new(@db[:recipient])
        visit(account_subscription_path(@db[:recipient]))
        expect(page).to have_text ActiveSupport::NumberHelper
          .number_to_currency(payment.plan_cost, unit: '£', precision: 0)
        expect(page).not_to have_text 'Contact us for a quote'
        expect(page).not_to have_link 'Get in touch',
                                      href: 'mailto:support@beehivegiving.org'
      end
    end

    scenario 'valid coupon' do
      visit account_upgrade_path(@db[:recipient])
      helper.pay_by_card(stripe, coupon: 'test10')
      @db[:recipient].reload
      expect(helper.stripe_subscription(@db[:recipient]).discount.coupon.id)
        .to eq 'test10'
    end

    scenario 'invalid coupon' do
      visit account_upgrade_path(@db[:recipient])
      helper.pay_by_card(stripe, coupon: 'invalid')
      expect(page).to have_text 'Invalid coupon'
    end

    context 'inactive' do
      scenario 'is inactive' do
        expect(@db[:recipient].subscription.active).to eq false
      end

      scenario 'plan expiry shown' do
        visit(account_subscription_path(@db[:recipient]))
        expect(page).to have_text 'does not expire'
      end

      scenario 'can view current subscription' do
        visit(account_subscription_path(@db[:recipient]))
        expect(current_path).to eq account_subscription_path(@db[:recipient])
        expect(page).to have_text 'currently subscribed to a free Basic plan'
      end

      scenario 'can navigate to upgrade page' do
        visit(account_subscription_path(@db[:recipient]))
        click_on 'Upgrade'
        expect(current_path).to eq account_upgrade_path(@db[:recipient])
      end

      scenario 'can upgrade' do
        visit(account_upgrade_path(@db[:recipient]))
        helper.pay_by_card(stripe)
        @db[:recipient].reload

        expect(current_path).to eq thank_you_path(@db[:recipient])
        expect(@db[:recipient].subscribed?).to eq true
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
          visit(account_upgrade_path(@db[:recipient]))
          helper.pay_by_card(stripe)
          expect(page).to have_text msg
          Subscription.plans.keys.each do |plan|
            stripe.delete_plan(plan.to_s.parameterize)
          end
        end
      end

      scenario 'can only check 3 eligibilty'
      scenario 'can only see 6 funds'
    end

    context 'active' do
      before(:each) do
        visit(account_upgrade_path(@db[:recipient]))
        helper.pay_by_card(stripe)
        @db[:recipient].reload
      end

      scenario 'is active' do
        expect(@db[:recipient].subscription.active).to eq true
      end

      scenario 'cannot upgrade' do
        expect(page).not_to have_text 'Upgrade'

        visit account_upgrade_path(@db[:recipient])
        expect(current_path).to eq account_subscription_path(@db[:recipient])
      end

      scenario 'shows expiry date' do
        click_link 'Continue'
        expect(page).to have_text 'Pro plan which expires on ' +
                                  1.year.since.strftime('%d %b %Y')
      end

      scenario 'webhook invoice-payment-succeeded', type: :request do
        expect(helper.stripe_subscription(@db[:recipient]).cancel_at_period_end)
          .to eq false

        event = StripeMock.mock_webhook_event(
          'invoice.payment_succeeded',
          customer: helper.stripe_customer(@db[:recipient]).id
        )

        post '/webhooks/invoice-payment-succeeded',
             params: event.to_json,
             headers: { 'Content-Type': 'application/json' }

        expect(helper.stripe_subscription(@db[:recipient]).cancel_at_period_end)
          .to eq true
      end

      scenario 'webhook customer-subscription-deleted', type: :request do
        Subscription.last.update(percent_off: 10)

        expect(Subscription.last.active).to eq true
        expect(Subscription.last.percent_off).to eq 10
        expect(helper.stripe_subscription(@db[:recipient]).status)
          .to eq 'active'

        event = StripeMock.mock_webhook_event(
          'customer.subscription.deleted',
          customer: helper.stripe_customer(@db[:recipient]).id
        )

        post '/webhooks/customer-subscription-deleted',
             params: event.to_json,
             headers: { 'Content-Type': 'application/json' }

        expect(Subscription.last.active).to eq false
        expect(Subscription.last.percent_off).to eq 0
        expect(event.data.object.status).to eq 'canceled'
      end

      scenario 'remaining free checks hidden' do
        @app.setup_funds
        @db[:complete_proposal].save!
        visit proposal_fund_path(@db[:complete_proposal], Fund.first)
        expect(page).not_to have_button 'Check eligibility (3 left)'
      end

      scenario 'can have unlimited proposals'
      scenario 'can check unlimited eligibilty'
      scenario 'can see unlimited funds'
    end
  end
end
