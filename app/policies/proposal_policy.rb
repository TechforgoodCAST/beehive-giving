class ProposalPolicy < ApplicationPolicy
  def create?
    user.subscription_active?
  end
end
