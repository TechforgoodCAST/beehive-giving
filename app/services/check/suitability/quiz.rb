module Check
  module Suitability
    class Quiz
      def initialize(proposal, funds)
        @answers = lookup_answers(proposal)
        @priorities = funds.includes(:priorities)
                           .pluck(:slug, 'criteria.id')
                           .group_by{|i| i[0]}
                           .map{ |k,v| [k, v.map{|j| j[1]}.select{|j| j.present?}]}
                           .to_h
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

        def lookup_answers(proposal)
          ::Answer.where(category_id: [proposal.id, proposal.recipient.id])
                  .pluck(:criterion_id, :eligible).to_h
        end

        def score(comparison, fund)
          @answers.slice(*comparison).values.select { |i| i == true }.count / @priorities[fund.slug].to_a.count.to_f
        end
    end
  end
end
