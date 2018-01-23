module Rating
  module Eligibility
    class Amount
      include Rating::Base

      def message
        { 0 => ineligible_message, 1 => eligible_message }[state]
      end

      def title
        'Amount'
      end

      protected

        def state
          assessment&.eligibility_amount
        end

      private

        def eligible_message
          return unless assessment
          "Awards grants <strong>#{assessment.fund.amount_desc}</strong>."
        end

        def ineligible_message
          'You are ineligible due to the <strong>amount</strong> your are ' \
          'seeking.'
        end
    end
  end
end
