module Check
  module Eligibility
    class Quiz
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_quiz = eligibility
        assessment.eligibility_quiz_failing = failing
        build_reason(assessment.eligibility_quiz, reasons)
        assessment
      end

      private

        def answers
          (pluck(:recipient) + pluck(:proposal)).to_h
        end

        def comparison
          answers.keys & restrictions
        end

        def eligibility
          if incomplete?
            # TODO: update message
            reasons << 'incomplete'
            return UNASSESSED
          end

          if !answers.slice(*comparison).values.uniq.include?(false)
            ELIGIBLE
          else
            # TODO: update message
            reasons << "#{failing} failing"
            INELIGIBLE
          end
        end

        def failing
          return if incomplete?

          answers.slice(*comparison).values.select { |i| i == false }.size
        end

        def incomplete?
          comparison.size != restrictions.size
        end

        def pluck(relation)
          assessment.send(relation).answers.pluck(:criterion_id, :eligible)
        end

        def restrictions
          assessment.fund.restriction_ids
        end
    end
  end
end
