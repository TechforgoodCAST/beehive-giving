class EnquiryPolicy < ApplicationPolicy
  def create?
    use_subscription_version(__method__)
  end

  private

    def v1_create?
      return true if user.subscription_active?
      record.proposal.eligible?(record.fund.slug)
    end

    def v2_create?
      return false unless record.fund
      return true if user.subscription_active?
      user.reveals.include?(record.fund.slug)
    end
end
