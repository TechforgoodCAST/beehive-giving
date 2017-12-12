module Check
  module Eligibility
    class Quiz
      include Check::Helpers

      def initialize(proposal, funds)
        @answers = lookup_answers(proposal)
        @restrictions = lookup_questions(funds, 'Restriction')
      end

      def call(_proposal, fund)
        raise 'Invalid Fund' unless fund.is_a? Fund
        comparison = (@answers.keys & @restrictions[fund.slug].to_a)
        return unless comparison.size == @restrictions[fund.slug].to_a.size
        {
          'eligible' => eligible?(comparison),
          'count_failing' => count_failing(comparison)
        }
      end

      private

        def eligible?(comparison)
          !@answers.slice(*comparison).values.include?(false)
        end

        def count_failing(comparison)
          @answers.slice(*comparison).values.select { |i| i == false }.size
        end
    end
  end
end
