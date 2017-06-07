class Recommender
  def initialize(funds, proposal)
    @funds = funds
    @proposal = proposal
    validate_arguments
  end

  private

    def validate_arguments
      raise 'Invalid Fund::ActiveRecord_Relation' unless
        @funds.instance_of? Fund::ActiveRecord_Relation
      raise 'Invalid Proposal object' unless @proposal.instance_of? Proposal
    end
end
