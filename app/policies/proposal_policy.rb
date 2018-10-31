class ProposalPolicy < ApplicationPolicy
  def create?
    record && record.proposal.nil?
  end
end
