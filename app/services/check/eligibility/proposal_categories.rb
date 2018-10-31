module Check
  module Eligibility
    class ProposalCategories
      include Check::Base

      def call(assessment)
        super
        return unless proposal_categories.any?

        assessment.eligibility_proposal_categories = eligibility
        build_reason(assessment.eligibility_proposal_categories, reasons)
        assessment
      end

      private

        def category
          assessment.proposal.category_code
        end

        def category_name
          assessment.proposal.category_name
        end

        def eligibility
          if proposal_categories.include?(category)
            reasons << if Proposal::CATEGORIES['Grant funding'][category]
                         reason('grant_funding_eligible')
                       else
                         reason('other_eligible')
                       end
            ELIGIBLE
          else
            reasons << if Proposal::CATEGORIES['Grant funding'][category]
                         reason('grant_funding_ineligible')
                       else
                         reason('other_ineligible')
                       end
            INELIGIBLE
          end
        end

        def proposal_categories
          assessment.fund.proposal_categories
        end

        def reason(id)
          { id: id, fund_value: proposal_categories, proposal_value: category }
        end
    end
  end
end
