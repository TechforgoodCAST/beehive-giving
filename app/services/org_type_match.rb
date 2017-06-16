class OrgTypeMatch # TODO: refactor rename
  def initialize(proposal) # TODO: refactor
    raise 'Invalid Proposal object' unless proposal.is_a? Proposal
    @proposal = proposal
  end

  def check(fund)
    {
      'eligible' => fund.permitted_org_types
                        .include?(@proposal.recipient.org_type)
    }
  end
end
