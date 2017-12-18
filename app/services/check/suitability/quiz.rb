module Check
  module Suitability
    class Quiz
      include Check::Helpers

      def initialize(proposal, funds)
        @answers = lookup_answers(proposal)
        @priorities = lookup_questions(funds, 'Priority')
      end

      def call(_proposal, fund)
        raise 'Invalid Fund' unless fund.is_a? Fund
        return unless @priorities[fund.slug].present?
        comparison = (@answers.keys & @priorities[fund.slug])
        return unless comparison.count == @priorities[fund.slug].count
        {
          'score' => score(comparison, fund)
        }
      end

      private

        def score(comparison, fund)
          @answers.slice(*comparison).values
                  .select { |i| i == true }
                  .count / @priorities[fund.slug].to_a.size.to_f
        end
    end
  end
end
