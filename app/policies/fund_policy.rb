class FundPolicy < ApplicationPolicy
  def show?
    return false unless record.fund && record.proposal
    return true if user.subscribed?
    record.proposal
          .suitable_funds
          .pluck(0)
          .take(RECOMMENDATION_LIMIT)
          .include?(record.fund.slug)
  end
end
