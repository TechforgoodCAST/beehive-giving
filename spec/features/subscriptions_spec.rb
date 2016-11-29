require 'rails_helper'
require_relative '../support/subscriptions_helper'
require 'stripe_mock'

feature 'Subscriptions' do

  let(:subscriptions_helper) { SubscriptionsHelper.new }
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

    context 'inactive' do
      scenario 'is inactive' do
        expect(@db[:recipient].subscription.active).to eq false
      end

      # TODO:
      scenario 'can view current subscription'
      #   visit(account_subscription_path(@db[:recipient]))
      #   expect(current_path).to eq account_subscription_path(@db[:recipient])
      #   expect(page).to have_text 'currently subscribed to a free Basic plan'
      # end

      scenario 'can navigate to upgrade page'
      #   visit(account_subscription_path(@db[:recipient]))
      #   click_on 'Upgrade'
      #   expect(current_path).to eq account_upgrade_path(@db[:recipient])
      # end

      scenario 'can upgrade'
      #   visit(account_upgrade_path(@db[:recipient]))
      #   subscriptions_helper.pay_by_card(stripe)
      #   @db[:recipient].reload
      #
      #   expect(current_path).to eq account_subscription_path(@db[:recipient])
      #   expect(@db[:recipient].is_subscribed?).to eq true
      # end

      scenario 'can only have 1 proposal'
      scenario 'can only check 3 eligibilty'
      scenario 'can only see 6 funds'

    end

    context 'active' do
      before(:each) do
        visit(account_upgrade_path(@db[:recipient]))
        subscriptions_helper.pay_by_card(stripe)
        @db[:recipient].reload
      end

      # TODO:
      scenario 'is active'
      #   expect(@db[:recipient].subscription.active).to eq true
      # end

      scenario 'cannot upgrade'
      #   expect(page).not_to have_text 'Upgrade'
      #
      #   visit account_upgrade_path(@db[:recipient])
      #   expect(current_path).to eq account_subscription_path(@db[:recipient])
      # end

      scenario 'shows expiry date'
      #   expect(page).to have_text "Pro plan which expires on "\
      #                             "#{1.year.since.strftime("#{1.year.since.day.ordinalize} %B %Y")}"
      # end

      scenario 'can have unlimited proposals'
      scenario 'can check unlimited eligibilty'
      scenario 'can see unlimited funds'
    end
  end
end
