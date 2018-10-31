module Check
  module Suitability
    class Quiz
      include Check::Base

      def call(assessment)
        super
        return unless priorities.any?

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
            reasons << reason('incomplete')
            return UNASSESSED
          end

          if !answers.slice(*comparison(priorities)).values.uniq.include?(false)
            reasons << reason('eligible')
            ELIGIBLE
          else
            reasons << reason('ineligible')
            INELIGIBLE
          end
        end

        def reason(id)
          { id: id, fund_value: priorities, proposal_value: answers }
        end
    end
  end
end
