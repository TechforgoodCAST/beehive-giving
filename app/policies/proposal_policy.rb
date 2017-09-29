class ProposalPolicy < ApplicationPolicy
  def new?
    user.subscribed?
  end
end
