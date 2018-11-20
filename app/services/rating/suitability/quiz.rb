module Rating
  module Suitability
    class Quiz
      include Rating::Base

      def link
        # TODO: removed for v3 deplpy
        # "<a href='##{@assessment_id}'>View answers</a>".html_safe
      end

      private

        def eligible(fund_value, proposal_value)
          'You meet all of the priorities set by this opportunity'
        end

        def incomplete(fund_value, proposal_value)
          'The priorities for this opportunity have changed, ' \
          'and your answers are incomplete'
        end

        def ineligible(fund_value, proposal_value)
          failing = proposal_value.slice(*fund_value.map(&:to_s))
                                  .count { |_k, v| v == false }
          "You do not meet #{failing} of the priorities for this opportunity"
        end
    end
  end
end
