module Check
  module Eligibility
    class OrgType
      include Check::Base

      def call(proposal, fund)
        validate_call(proposal, fund)
        {
          'eligible' => fund.permitted_org_types
                            .include?(proposal.recipient.org_type)
        }
      end
    end
  end
end
