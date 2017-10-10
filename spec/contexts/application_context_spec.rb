require 'rails_helper'

describe ApplicationContext do
  subject do
    ApplicationContext.new(fund, proposal)
  end

  let(:fund) { Fund.new(slug: 'fund') }
  let(:proposal) { Proposal.new }

  it 'requires #policy_class' do
    expect { subject.class.policy_class }
      .to raise_error(NotImplementedError)
  end

  it '#slug' do
    expect(subject.slug).to eq 'fund'
  end
end
