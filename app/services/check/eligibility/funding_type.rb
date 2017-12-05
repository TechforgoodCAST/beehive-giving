module Check
  module Eligibility
    class FundingType
      include Check::Base

      def call(proposal, fund)
        validate_call(proposal, fund)
        {
          'eligible' => fund.permitted_costs
                            .include?(proposal.funding_type)
        }
      end
    end
  end
end
