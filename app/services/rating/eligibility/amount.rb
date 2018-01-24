module Rating
  module Eligibility
    class Amount
      include Rating::Base

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
