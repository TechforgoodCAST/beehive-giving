require 'rails_helper'

describe FundContext do
  it 'self.policy_class' do
    expect(FundContext.policy_class).to eq FundPolicy
  end
end
