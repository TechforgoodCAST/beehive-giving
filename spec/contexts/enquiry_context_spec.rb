require 'rails_helper'

describe EnquiryContext do
  subject { described_class }

  it 'self.policy_class' do
    expect(subject.policy_class).to eq EnquiryPolicy
  end
end
