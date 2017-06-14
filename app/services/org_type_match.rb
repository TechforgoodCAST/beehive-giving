class OrgTypeMatch
  def initialize(fund, proposal)
    @fund = fund
    @proposal = proposal
    validate_arguments
  end

  def check
    {
      "eligible" => @fund.permitted_org_types.include?(@proposal.recipient.org_type)
    }
  end

  private

    def validate_arguments
      raise 'Invalid Fund object' unless @fund.instance_of? Fund
      raise 'Invalid Proposal object' unless @proposal.instance_of? Proposal
    end
end
