class EnquiryPolicy < ApplicationPolicy
  def create?
    use_subscription_version(__method__)
  end

  private

    def v1_create? # TODO: deprecated
      return true if user.subscription_active?
      _fund_policy_show? ? record.proposal.eligible?(record.fund.slug) : false
    end

    def v2_create?
      assessment&.eligibility_quiz == 1 ? _fund_policy_show? : false
    end

    def _fund_policy_show?
      FundPolicy.new(user, FundContext.new(record.fund, record.proposal)).show?
    end

    def assessment
      Assessment.find_by(fund: record.fund, proposal: record.proposal)
    end
end
