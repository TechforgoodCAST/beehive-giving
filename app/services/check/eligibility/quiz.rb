module Check
  module Eligibility
    class Quiz
      def initialize(proposal, funds)
        @answers = lookup_answers(proposal)
        @restrictions = funds.includes(:restrictions)
                             .pluck(:slug, 'criteria.id')
                             .group_by{|i| i[0]}
                             .map{ |k,v| [k, v.map{|j| j[1]}.select{|j| j.present?}]}
                             .to_h
      end

      def call(_proposal, fund)
        raise 'Invalid Fund' unless fund.is_a? Fund
        comparison = (@answers.keys & @restrictions[fund.slug].to_a)
        return unless comparison.count == @restrictions[fund.slug].to_a.count
        {
          'eligible' => eligible?(comparison),
          'count_failing' => count_failing(comparison)
        }
      end

      private

        def lookup_answers(proposal)
          ::Answer.where(category_id: [proposal.id, proposal.recipient.id])
                  .pluck(:criterion_id, :eligible).to_h
        end

        def eligible?(comparison)
          !@answers.slice(*comparison).values.include?(false)
        end

        def count_failing(comparison)
          @answers.slice(*comparison).values.select { |i| i == false }.count
        end
    end
  end
end
