module Check
  module Suitability
    class Quiz
      include Check::Base

      def call(assessment)
        super
        assessment.suitability_quiz = suitability
        assessment.suitability_quiz_failing = failing(priorities)
        build_reason(assessment.suitability_quiz, reasons)
        assessment
      end

      private

        def priorities
          assessment.fund.priority_ids
        end

        def suitability
          if incomplete?(priorities)
            reasons << 'The priorities for this opportunity have changed, ' \
                       'and your answers are incomplete'
            return UNASSESSED
          end

          if !answers.slice(*comparison(priorities)).values.uniq.include?(false)
            ELIGIBLE
          else
            reasons << "You do not meet #{failing(priorities)} of the " \
                       'priorities for this opportunity'
            INELIGIBLE
          end
        end
    end
  end
end
