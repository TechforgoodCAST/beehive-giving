require 'rails_helper'

describe FundContext do
  subject { described_class }

  it 'self.policy_class' do
    expect(subject.policy_class).to eq FundPolicy
  end
end
