module Check
  module Eligibility
    class Amount
      include Check::Base

      def call(proposal, fund)
        validate_call proposal, fund
        return eligible false if less_than_min_amount_awarded? proposal, fund
        return eligible false if more_than_max_amount_awarded? proposal, fund
        eligible true
      end

      private

        def less_than_min_amount_awarded?(proposal, fund)
          fund.min_amount_awarded_limited &&
            proposal.total_costs < fund.min_amount_awarded
        end

        def more_than_max_amount_awarded?(proposal, fund)
          fund.max_amount_awarded_limited &&
            proposal.total_costs > fund.max_amount_awarded
        end
    end
  end
end
