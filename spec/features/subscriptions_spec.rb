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
          .create_registered_proposal
          .sign_in
      @db = @app.instances
    end

    scenario 'plan/price set by recipient.income'
    scenario 'invalid card details'
    scenario 'valid coupon'
    scenario 'invalid coupon'
    scenario 'plan name shown'
    scenario 'plan cost shown'
    scenario 'plan expiry shown'
    scenario 'plan tier explained'

    context 'inactive' do
      scenario 'is inactive' do
        expect(@db[:recipient].subscription.active).to eq false
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

        expect(current_path).to eq account_subscription_path(@db[:recipient])
        expect(@db[:recipient].subscribed?).to eq true
      end

      scenario 'can only have 1 proposal' do
        @app.build_complete_proposal
        proposal = @app.instances[:complete_proposal]
        expect(proposal).not_to be_valid
        expect(proposal.errors[:title][0]).to eq 'Upgrade subscription to ' \
                                                 'create multiple proposals'
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
        expect(page).to have_text 'Pro plan which expires on ' +
                                  1.year.since.strftime(
                                    "#{1.year.since.day.ordinalize} %B %Y"
                                  )
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
        expect(Subscription.last.active).to eq true
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
        expect(event.data.object.status).to eq 'canceled'
      end

      scenario 'can have unlimited proposals'
      scenario 'can check unlimited eligibilty'
      scenario 'can see unlimited funds'
    end
  end
end
