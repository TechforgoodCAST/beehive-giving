module Check
  module Eligibility
    class Quiz
      include Check::Base

      def call(assessment)
        super
        return unless restrictions.any?

        assessment.eligibility_quiz = eligibility
        assessment.eligibility_quiz_failing = failing(restrictions)
        build_reason(assessment.eligibility_quiz, reasons)
        assessment
      end

      private

        def eligibility
          if incomplete?(restrictions)
            reasons << reason('incomplete')
            return UNASSESSED
          end

          if !answers.slice(*comparison(restrictions)).values.uniq.include?(false)
            reasons << reason('eligible')
            ELIGIBLE
          else
            reasons << reason('ineligible')
            INELIGIBLE
          end
        end

        def reason(id)
          { id: id, fund_value: restrictions, proposal_value: answers }
        end

        def restrictions
          assessment.fund.restriction_ids
        end
    end
  end
end
