module Check
  module Eligibility
    class Amount
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_amount = eligibility
        assessment
      end

      private

        def eligibility
          if less_than_min_amount_awarded? || more_than_max_amount_awarded?
            INELIGIBLE
          else
            ELIGIBLE
          end
        end

        def min_amount_awarded_limited?
          assessment.fund&.min_amount_awarded_limited?
        end

        def min_amount_awarded
          assessment.fund&.min_amount_awarded
        end

        def max_amount_awarded_limited?
          assessment.fund&.max_amount_awarded_limited?
        end

        def max_amount_awarded
          assessment.fund&.max_amount_awarded
        end

        def total_costs
          assessment.proposal&.total_costs
        end

        def less_than_min_amount_awarded?
          min_amount_awarded_limited? && (total_costs < min_amount_awarded)
        end

        def more_than_max_amount_awarded?
          max_amount_awarded_limited? && (total_costs > max_amount_awarded)
        end
    end
  end
end
