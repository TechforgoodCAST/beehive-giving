class ApplicationContext
  attr_reader :fund, :proposal

  def self.policy_class
    raise NotImplementedError
  end

  def initialize(fund, proposal)
    @fund = fund
    @proposal = proposal
  end
end
