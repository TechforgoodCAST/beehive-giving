module Check
  module Eligibility
    class ProposalCategories
      include Check::Base

      def call(assessment)
        super
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
            ELIGIBLE
          else
            if Proposal::CATEGORIES['Grant funding'][category]
              reasons << "Does not provide #{category_name} grants"
            else
              reasons << "Does not provide the type of support you're seeking"
            end
            INELIGIBLE
          end
        end

        def proposal_categories
          assessment.fund.proposal_categories
        end
    end
  end
end
