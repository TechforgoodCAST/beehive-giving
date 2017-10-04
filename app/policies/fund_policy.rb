class FundPolicy < ApplicationPolicy
  def show?
    use_subscription_version(__method__)
  end

  private

    def v1_show?
      return false unless record.fund && record.proposal
      return true if user.subscription_active?
      record.proposal
            .suitable_funds
            .pluck(0)
            .take(RECOMMENDATION_LIMIT)
            .include?(record.fund.slug)
    end

    def v2_show?
      return false unless record
      return true if user.subscription_active?
      user.reveals.include?(record.slug)
    end
end
