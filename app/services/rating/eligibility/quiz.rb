module Rating
  module Eligibility
    class Quiz
      include Rating::Base

      def link
        "<a data-remote='true' rel='nofollow' " \
        "href='/assessments/#{@assessment_id}/answers" \
        "?criteria_type=restrictions'>View answers</a>".html_safe
      end

      private

        def eligible(fund_value, proposal_value)
          'You meet all of the restrictions set by this opportunity'
        end

        def incomplete(fund_value, proposal_value)
          'The restrictions for this opportunity have changed, ' \
          'and your answers are incomplete'
        end

        def ineligible(fund_value, proposal_value)
          failing = proposal_value.slice(*fund_value.map(&:to_s))
                                  .count { |_k, v| v == false }
          "You do not meet #{failing} of the restrictions for this opportunity"
        end
    end
  end
end
