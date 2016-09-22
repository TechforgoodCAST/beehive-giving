require 'rails_helper'

describe Subscription do
  it 'belongs to organisation' do
    @app.create_recipient
    recipient = @app.instances[:recipient]
    subscription = Subscription.last
    expect(subscription).to eq recipient.subscription
  end
end
