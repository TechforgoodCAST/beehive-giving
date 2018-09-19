require 'rails_helper'
require 'pundit/rspec'

describe ProposalPolicy do
  subject { described_class }

  permissions :new?, :create? do
    it 'grants access if `record` without Proposal' do
      record = build(:recipient)
      is_expected.to permit(nil, record)
    end

    it 'denies access if `record` missing' do
      is_expected.not_to permit(nil, nil)
    end

    it 'denies access `record` has Proposal' do
      proposal = build(:proposal)
      record = proposal.recipient
      is_expected.not_to permit(nil, record)
    end
  end
end
