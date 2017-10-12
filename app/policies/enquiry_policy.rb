class EnquiryPolicy < ApplicationPolicy
  def create?
    use_subscription_version(__method__)
  end

  private

    def v1_create?
      return true if user.subscription_active?
      _fund_policy_show? ? record.proposal.eligible?(record.fund.slug) : false
    end

    def v2_create?
      _fund_policy_show?
    end

    def _fund_policy_show?
      FundPolicy.new(user, FundContext.new(record.fund, record.proposal)).show?
    end
end
