module Check
  module Eligibility
    class FundingType
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_funding_type = eligibility
        assessment
      end

      private

        def eligibility
          permitted_costs.include?(funding_type) ? 1 : 0
        end

        def permitted_costs
          assessment.fund&.permitted_costs
        end

        def funding_type
          assessment.proposal&.funding_type
        end
    end
  end
end
