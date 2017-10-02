class ProposalPolicy < ApplicationPolicy
  def new?
    user.subscribed?
  end

  def create?
    user.subscribed?
  end
end
