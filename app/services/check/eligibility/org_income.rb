module Check
  module Eligibility
    class OrgIncome
      include Check::Base

      def call(proposal, fund)
        validate_call proposal, fund
        return eligible false if less_than_min_income? proposal, fund
        return eligible false if more_than_max_income? proposal, fund
        eligible true
      end

      private

        def less_than_min_income?(proposal, fund)
          fund.min_org_income_limited &&
            proposal.recipient.max_income < fund.min_org_income
        end

        def more_than_max_income?(proposal, fund)
          fund.max_org_income_limited &&
            proposal.recipient.min_income > fund.max_org_income
        end
    end
  end
end
