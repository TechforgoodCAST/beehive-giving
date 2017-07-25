class Recommender # TODO: refactor
  def initialize(funds, proposal)
    @funds = funds
    @proposal = proposal
    validate_arguments
  end

  private

    def validate_arguments
      raise 'Invalid Fund::ActiveRecord_Relation' unless
        @funds.class.to_s == 'Fund::ActiveRecord_Relation'
      raise 'Invalid Proposal object' unless @proposal.is_a? Proposal
    end
end
