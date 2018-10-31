module Rating
  module Eligibility
    class Amount
      include Rating::Base

      private

        def above_max(fund_value, proposal_value)
          "The maximum amount you're seeking (#{proposal_value}) "\
          "is more than the maximum awarded (#{fund_value})"
        end

        def below_min(fund_value, proposal_value)
          "The minimum amount you're seeking (#{proposal_value}) "\
          "is less than the minimum awarded (#{fund_value})"
        end
    end
  end
end
