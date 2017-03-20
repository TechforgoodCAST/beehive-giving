require 'rails_helper'

describe Payment do
  let(:helper) { SubscriptionsHelper.new }
  let(:stripe) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  it 'requires Recipient to initialize' do
    expect { Payment.new }.to raise_error(ArgumentError)
  end

  it '#plan_cost' do
    [50, 100, 300, 1200].each_with_index do |price, i|
      payment = Payment.new(build(:recipient, income: i))
      expect(payment.plan_cost).to eq price
    end
  end

  context 'with recipient' do
    before(:each) do
      @app.seed_test_db.create_recipient.with_user
      @db = @app.instances
      @recipient = @db[:recipient]
      @user = @db[:user]
      @payment = Payment.new(@recipient)
      helper.send(:create_stripe_plans, stripe)
      helper.send(:create_stripe_coupons, stripe)
    end

    it '#process! with empty coupon' do
      expect(@payment.process!(stripe.generate_card_token, @user, ''))
        .to eq true
      expect(Subscription.last.active?).to eq true
    end

    it '#process! with invalid coupon' do
      expect(@payment.process!('token', @user, 'invalid')).to eq false
      expect(Subscription.last.active?).to eq false
    end

    it '#process! updates Subscription.expiry_date'
    it '#process! updates Subscription.discount'
  end
end
