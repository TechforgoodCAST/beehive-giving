module Check # TODO: deprecated
  module Helpers
    private

      def lookup_answers(proposal)
        Answer.where(category_id: [proposal.id, proposal.recipient.id])
              .pluck(:criterion_id, :eligible).to_h
      end

      def lookup_questions(funds, type)
        funds.find_by_sql(['
          SELECT funds.slug AS slug,
                 array_agg(questions.criterion_id) AS criteria_ids
          FROM funds
          INNER JOIN questions ON funds.id = questions.fund_id
          WHERE questions.criterion_type = ?
          GROUP BY funds.slug
        ', type]).pluck('slug', 'criteria_ids').to_h
      end
  end
end
