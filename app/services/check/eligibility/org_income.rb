module Check
  module Eligibility
    class OrgIncome
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_org_income = eligibility
        assessment
      end

      private

        def eligibility
          less_than_min_income? || more_than_max_income? ? 0 : 1
        end

        def min_org_income_limited?
          assessment.fund.min_org_income_limited?
        end

        def min_org_income
          assessment.fund.min_org_income
        end

        def max_org_income_limited?
          assessment.fund.max_org_income_limited?
        end

        def max_org_income
          assessment.fund.max_org_income
        end

        def min_income
          assessment.recipient.min_income
        end

        def max_income
          assessment.recipient.max_income
        end

        def less_than_min_income?
          min_org_income_limited? && (max_income < min_org_income)
        end

        def more_than_max_income?
          max_org_income_limited? && (min_income > max_org_income)
        end
    end
  end
end
