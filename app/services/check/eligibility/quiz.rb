module Check
  module Eligibility
    class Quiz
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_quiz = eligibility
        assessment.eligibility_quiz_failing = failing(restrictions)
        build_reason(assessment.eligibility_quiz, reasons)
        assessment
      end

      private

        def eligibility
          if incomplete?(restrictions)
            reasons << 'The restrictions for this opportunity have changed, ' \
                       'and your answers are incomplete'
            return UNASSESSED
          end

          if !answers.slice(*comparison(restrictions)).values.uniq.include?(false)
            ELIGIBLE
          else
            reasons << "You do not meet #{failing(restrictions)} of the " \
                       'restrictions for this opportunity'
            INELIGIBLE
          end
        end

        def restrictions
          assessment.fund.restriction_ids
        end
    end
  end
end
