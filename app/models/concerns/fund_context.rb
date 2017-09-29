class FundContext
  attr_reader :fund, :proposal

  def self.policy_class
    FundPolicy
  end

  def initialize(fund, proposal)
    @fund = fund
    @proposal = proposal
  end
end
