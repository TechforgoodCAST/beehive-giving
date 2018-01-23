module Rating
  module Eligibility
    class OrgIncome
      include Rating::Base

      def message
        { 0 => ineligible_message, 1 => eligible_message }[state]
      end

      def title
        'Income'
      end

      protected

        def state
          assessment&.eligibility_org_income
        end

      private

        def eligible_message
          return unless assessment
          'Awards funds to organisations with ' \
          "<strong>#{assessment.fund.org_income_desc}</strong> income."
        end

        def ineligible_message
          'You are ineligible due to your <strong>income</strong>.'
        end
    end
  end
end
