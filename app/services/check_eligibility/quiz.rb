class CheckEligibility
  class Quiz
    def initialize(proposal) # TODO: refactor parent class
      @proposal = proposal
      raise 'Invalid Proposal object' unless @proposal.instance_of? Proposal
    end

    def check(fund) # TODO: rename & refactor Assignment Branch Condition size
      restrictions = fund.restriction_ids
      answers = lookup_answers
      comparison = (answers.keys & restrictions)
      return unless comparison.count == restrictions.count
      {
        'eligible' => !answers.slice(*comparison).values.include?(false),
        'count_failing' => answers.slice(*comparison).values
                                  .select { |i| i == false }.count
      }
    end

    private

      def lookup_answers # TODO: refactor avoid db call
        Eligibility.where(category_id: [@proposal.id, @proposal.recipient.id])
                   .pluck(:restriction_id, :eligible).to_h
      end
  end
end
