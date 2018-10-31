module Check
  module Eligibility
    class Amount
      include ActionView::Helpers::NumberHelper
      include Check::Base

      def call(assessment)
        super
        return unless seeking_funding?

        assessment.eligibility_amount = check_eligibility!
        build_reason(assessment.eligibility_amount, reasons)
        assessment
      end

      private

        def check_eligibility!
          less_than_min_amount = check_min_amount
          more_than_max_amount = check_max_amount

          if less_than_min_amount || more_than_max_amount
            INELIGIBLE
          else
            reasons << { id: 'eligible' }
            ELIGIBLE
          end
        end

        def check_min_amount
          if check_limit(:min_amount, :<, :proposal_min_amount)
            reasons << {
              id: 'below_min',
              fund_value: min_amount,
              proposal_value: proposal_min_amount
            }
            true
          else
            false
          end
        end

        def check_max_amount
          if check_limit(:max_amount, :>, :proposal_max_amount)
            reasons << {
              id: 'above_max',
              fund_value: max_amount,
              proposal_value: proposal_max_amount
            }
            true
          else
            false
          end
        end

        def min_amount
          to_currency(assessment.proposal.min_amount)
        end

        def max_amount
          to_currency(assessment.proposal.max_amount)
        end

        def proposal_min_amount
          to_currency(assessment.fund.proposal_min_amount)
        end

        def proposal_max_amount
          to_currency(assessment.fund.proposal_max_amount)
        end

        def seeking_funding?
          assessment.proposal.min_amount && assessment.proposal.max_amount
        end

        def to_currency(number)
          number_to_currency(number, unit: '£', precision: 0)
        end
    end
  end
end
