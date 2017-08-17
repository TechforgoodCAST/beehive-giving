class CheckEligibility
  class OrgIncome < CheckEligibility
    def call(proposal, fund)
      super
      return eligible false if (fund.min_org_income_limited && proposal.recipient.max_income < fund.min_org_income)
      return eligible false if (fund.max_org_income_limited && proposal.recipient.min_income > fund.max_org_income)
      eligible true
    end

    private

      def eligible(bool)
        { 'eligible' => bool }
      end
  end
end
