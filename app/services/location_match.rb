class LocationMatch
  def initialize(funds, proposal)
    @funds = funds
    @proposal = proposal
    validate_arguments
  end

  private

    def validate_arguments
      raise 'Invalid Fund::ActiveRecord_Relation' unless
        @funds.instance_of? Fund::ActiveRecord_Relation
      raise 'No funds supplied' if @funds.empty?
      raise 'Invalid Proposal object' unless @proposal.instance_of? Proposal
    end
end
