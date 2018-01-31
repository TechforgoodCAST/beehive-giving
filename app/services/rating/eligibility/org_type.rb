module Rating
  module Eligibility
    class OrgType
      include Rating::Base

      def title
        'Recipient'
      end

      protected

        def state
          assessment&.eligibility_org_type
        end

      private

        def eligible_message
          return unless assessment
          "Awards funds to <strong>#{org_type}</strong>."
        end

        def ineligible_message
          return unless assessment
          "Does not award funds to <strong>#{org_type}</strong>."
        end

        def org_type
          return unless assessment
          # TODO: refactor ORG_TYPES to avoid .drop(1)
          ORG_TYPES.drop(1)[assessment.recipient.org_type][2]
        end
    end
  end
end
