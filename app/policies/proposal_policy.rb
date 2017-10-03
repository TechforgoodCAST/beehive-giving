class ProposalPolicy < ApplicationPolicy
  def create?
    user.subscribed?
  end
end
