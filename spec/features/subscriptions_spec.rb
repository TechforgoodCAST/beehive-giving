require 'rails_helper'
require_relative '../support/recipient_helper'
require_relative '../support/subscriptions_helper'
require 'stripe_mock'

feature 'Subscriptions' do

  let(:recipient_helper) { RecipientHelper.new }
  let(:subscriptions_helper) { SubscriptionsHelper.new }
  let(:stripe) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  context 'signed in' do
    before(:each) do
      seed_test_db
      @app = recipient_helper.
        create_recipient.
        with_user.
        registered_proposal.
        sign_in
      @data = @app.instances
    end

    context 'inactive subscription' do
      scenario 'is inactive' do
        expect(@data[:recipient].subscription.active).to eq false
      end

      scenario 'can view current subscription' do
        visit(account_subscription_path(@data[:recipient]))
        expect(current_path).to eq account_subscription_path(@data[:recipient])
        expect(page).to have_text 'currently subscribed to a free Basic plan'
      end

      scenario 'can navigate to upgrade page' do
        visit(account_subscription_path(@data[:recipient]))
        click_on 'Upgrade'
        expect(current_path).to eq account_upgrade_path(@data[:recipient])
      end

      scenario 'can upgrade' do
        visit(account_upgrade_path(@data[:recipient]))
        subscriptions_helper.pay_by_card(stripe)
        @data[:recipient].reload

        expect(current_path).to eq account_subscription_path(@data[:recipient])
        expect(@data[:recipient].is_subscribed?).to eq true
      end
    end

    context 'active subscription' do
      before(:each) do
        visit(account_upgrade_path(@data[:recipient]))
        subscriptions_helper.pay_by_card(stripe)
        @data[:recipient].reload
      end

      scenario 'is active' do
        expect(@data[:recipient].subscription.active).to eq true
      end

      scenario 'cannot upgrade' do
        expect(page).not_to have_text 'Upgrade'

        visit account_upgrade_path(@data[:recipient])
        expect(current_path).to eq account_subscription_path(@data[:recipient])
      end

      scenario 'shows expiry date' do
        expect(page).to have_text "Pro plan which expires on "\
                                  "#{1.year.since.strftime("#{1.year.since.day.ordinalize} %B %Y")}"
      end
    end
  end
end
