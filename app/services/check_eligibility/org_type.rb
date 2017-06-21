class CheckEligibility
  class OrgType < CheckEligibility
    def call(proposal, fund)
      super
      {
        'eligible' => fund.permitted_org_types
                          .include?(proposal.recipient.org_type)
      }
    end
  end
end
