class CheckEligibility
  class OrgType < Setup
    def call(fund)
      {
        'eligible' => fund.permitted_org_types
                          .include?(@proposal.recipient.org_type)
      }
    end
  end
end
