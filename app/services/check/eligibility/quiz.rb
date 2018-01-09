module Check
  module Eligibility
    class Quiz
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_quiz = eligibility
        assessment.eligibility_quiz_failing = failing
        assessment
      end

      private

        def eligibility
          return unless complete?
          !answers.slice(*comparison).values.uniq.include?(false) ? 1 : 0
        end

        def failing
          return unless complete?
          answers.slice(*comparison).values.select { |i| i == false }.size
        end

        def restrictions
          assessment.fund.restriction_ids
        end

        def answers
          (pluck(:recipient) + pluck(:proposal)).to_h
        end

        def pluck(relation)
          assessment.send(relation).answers.pluck(:criterion_id, :eligible)
        end

        def comparison
          answers.keys & restrictions
        end

        def complete?
          comparison.size == restrictions.size
        end
    end
  end
end
