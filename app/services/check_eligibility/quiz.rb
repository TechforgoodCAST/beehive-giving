class CheckEligibility
  class Quiz < CheckEligibility
    def call(proposal, fund) # TODO: refactor Assignment Branch Condition size
      super
      restrictions = fund.restriction_ids
      answers = lookup_answers(proposal)
      comparison = (answers.keys & restrictions)
      return unless comparison.count == restrictions.count
      {
        'eligible' => !answers.slice(*comparison).values.include?(false),
        'count_failing' => answers.slice(*comparison).values
                                  .select { |i| i == false }.count
      }
    end

    private

      def lookup_answers(proposal) # TODO: refactor avoid db callq
        Eligibility.where(category_id: [proposal.id, proposal.recipient.id])
                   .pluck(:restriction_id, :eligible).to_h
      end
  end
end
