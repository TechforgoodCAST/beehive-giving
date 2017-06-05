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
    @app.create_recipient
    recipient = Recipient.last
    [50, 100, 300, 1200].each_with_index do |price, i|
      recipient.income = i
      payment = Payment.new(recipient)
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

    it '#plan_cost with discount' do
      @payment.process!(stripe.generate_card_token, @user, 'test10')
      expect(@payment.plan_cost).to eq 90
    end

    it '#process! with empty coupon' do
      expect(@payment.process!(stripe.generate_card_token, @user, ''))
        .to eq true
      expect(@recipient.subscription.active?).to eq true
    end

    it '#process! with invalid coupon' do
      expect(@payment.process!('token', @user, 'invalid')).to eq false
      expect(@recipient.subscription.active?).to eq false
    end

    it '#process! updates Subscription.expiry_date' do
      @payment.process!(stripe.generate_card_token, @user, '')
      expect(@recipient.subscription.expiry_date).to eq 1.year.from_now.to_date
    end

    it '#process! updates Subscription.percent_off' do
      @payment.process!(stripe.generate_card_token, @user, 'test10')
      expect(@recipient.subscription.percent_off).to eq 10
    end

    it '#discount returns percentage' do
      @payment.process!(stripe.generate_card_token, @user, 'test10')
      expect(@payment.discount).to eq '10%'
    end

    it '#discount not positive' do
      expect(@payment.discount).to eq false
    end
  end
end
