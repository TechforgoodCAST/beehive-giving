require 'rails_helper'

describe Payment do
  subject { Payment.new(amount: 1999) }

  let(:stripe) { StripeMock.create_test_helper }
  let(:user) { create(:user) }

  before { StripeMock.start }
  after { StripeMock.stop }

  it 'requires `amount` to initialize' do
    expect { Payment.new }.to raise_error('amount required')
  end

  it 'multiple Charges added to same Stripe::Customer' do
    2.times { subject.process!(user, stripe.generate_card_token) }
    customer = user.stripe_user_id
    expect(Stripe::Charge.list(customer: customer).data.size).to eq(2)
  end

  it 'persisted User creates Stripe::Customer' do
    expect(Stripe::Customer.list.data.size).to eq(0)
    subject.process!(user, stripe.generate_card_token)
    expect(Stripe::Customer.list.data.size).to eq(1)
  end

  context 'unpersisted User' do
    let(:user) { OpenStruct.new(email: 'email@example.com') }

    it 'creates Stripe::Customer' do
      expect(Stripe::Customer.list.data.size).to eq(0)
      subject.process!(user, stripe.generate_card_token)
      expect(User.count).to eq(0)
      expect(Stripe::Customer.list.data.size).to eq(1)
    end
  end
end
