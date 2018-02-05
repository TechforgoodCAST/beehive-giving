module Rating
  module Eligibility
    class Quiz
      include Rating::Base

      def colour
        {
          UNASSESSED => 'blue', INELIGIBLE => 'red', ELIGIBLE   => 'green'
        }[state]
      end

      def message
        {
          UNASSESSED => '-',
          INELIGIBLE => ineligible_message,
          ELIGIBLE   => eligible_message
        }[state]
      end

      def status
        {
          UNASSESSED => 'Incomplete',
          INELIGIBLE => 'Ineligible',
          ELIGIBLE   => 'Eligible'
        }[state]
      end

      def title
        'Quiz'
      end

      protected

        def state
          assessment&.eligibility_quiz
        end

      private

        def eligible_message
          '-'
        end

        def ineligible_message
          return unless assessment
          'You are ineligible, and do not meet ' \
          "<strong>#{assessment.eligibility_quiz_failing}</strong> " \
          'of the criteria below.'
        end
    end
  end
end
