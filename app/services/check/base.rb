module Check
  module Base
    def eligible(bool)
      { 'eligible' => bool }
    end

    def validate_call(proposal, fund)
      raise 'Invalid Proposal' unless proposal.is_a? Proposal
      raise 'Invalid Fund' unless fund.is_a? Fund
    end
  end
end
