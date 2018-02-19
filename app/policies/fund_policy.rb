class FundPolicy < ApplicationPolicy
  def show?
    return false unless record.fund
    return true if record.featured || record.stub?
    return false unless record.proposal
    return true if user.subscription_active?
    user.reveals.include?(record.slug)
  end
end
