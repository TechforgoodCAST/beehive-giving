require 'rails_helper'

describe Subscription do
  it 'belongs to organisation' do
    @app.create_recipient
    recipient = @app.instances[:recipient]
    subscription = Subscription.last
    expect(subscription).to eq recipient.subscription
  end

  it 'self.plans' do
    plans = {
      'v3 Pro - Micro' => 2400,
      'v3 Pro - Small' => 4800,
      'v3 Pro - Medium' => 9600,
      'v3 Pro - Large' => 19_200,
      'v3 Pro - Major' => 38_400
    }
    expect(Subscription.plans).to eq plans
  end

  it 'self.plans empty STRIPE_PLANS' do
    ClimateControl.modify STRIPE_PLANS: nil do
      expect { Subscription.plans }
        .to raise_error 'STRIPE_PLANS environment variable not set'
    end
  end

  it 'self.plans invalid STRIPE_PLANS' do
    ClimateControl.modify STRIPE_PLANS: 'invalid' do
      expect { Subscription.plans }
        .to raise_error 'Must have format <name>:<amount>'
    end
  end
end
