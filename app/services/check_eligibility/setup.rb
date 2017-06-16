class CheckEligibility
  class Setup
    def initialize(proposal)
      raise 'Invalid Proposal object' unless proposal.is_a? Proposal
      @proposal = proposal
    end
  end
end
