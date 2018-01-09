module Check
  module Eligibility
    class OrgType
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_org_type = eligibility
        assessment
      end

      private

        def eligibility
          permitted_org_types.include?(org_type) ? 1 : 0
        end

        def permitted_org_types
          assessment.fund&.permitted_org_types
        end

        def org_type
          assessment.recipient&.org_type
        end
    end
  end
end
