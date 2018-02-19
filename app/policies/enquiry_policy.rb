class EnquiryPolicy < ApplicationPolicy
  def create?
    assessment&.eligibility_status == ELIGIBLE ? _fund_policy_show? : false
  end

  private

    def _fund_policy_show?
      FundPolicy.new(user, FundContext.new(record.fund, record.proposal)).show?
    end

    def assessment
      Assessment.find_by(fund: record.fund, proposal: record.proposal)
    end
end
