module Rating
  module Eligibility
    class Quiz
      include Rating::Base

      def colour
        { nil => 'blue', 0 => 'red', 1 => 'green' }[state] || 'grey'
      end

      def message
        { nil => '-', 0 => ineligible_message, 1 => eligible_message }[state]
      end

      def status
        { nil => 'Incomplete', 0 => 'Ineligible', 1 => 'Eligible' }[state]
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
