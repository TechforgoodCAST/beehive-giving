require 'rails_helper'
require 'pundit/rspec'

fdescribe RequestPolicy do
  subject { described_class }

  let(:subscribed) { false }
  let(:fund) { Fund.new(slug: 'fund') }
  let(:proposal) { Proposal.new(suitability: suitability) }
  let(:requests) { [] }
  let(:user) do
    instance_double(
      User,
      subscription_active?: subscribed,
      subscription_version: version
    )
  end
  let(:recipient) { Recipient.new() }
 
  permissions :create? do
    it 'not subscribed' do
      is_expected.not_to permit(user, :requests)
    end

    it 'subscribed' do
      let(:subscribed){ true }
      is_expected.to permit(user, :requests)
    end
  end
end
