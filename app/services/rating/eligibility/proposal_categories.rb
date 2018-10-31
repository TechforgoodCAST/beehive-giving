module Rating
  module Eligibility
    class ProposalCategories
      include Rating::Base

      private

        def category_name(category_code)
          Proposal::CATEGORIES.values.reduce({}, :merge)[category_code]
        end

        def category_names(category_codes)
          category_codes.map do |category_code|
            Proposal::CATEGORIES.values.reduce({}, :merge)[category_code]
          end
        end

        def grant_funding_eligible(fund_value, proposal_value)
          "Provides #{category_name(proposal_value)} grant funding"
        end

        def grant_funding_ineligible(fund_value, proposal_value)
          "Only provides #{category_names(fund_value).to_sentence} grant fund" \
          "ing, and you are seeking #{category_name(proposal_value)} funding"
        end

        def other_eligible(fund_value, proposal_value)
          "Provides '#{category_name(proposal_value)}' support, contact the " \
          'provider directly for more details'
        end

        def other_ineligible(fund_value, proposal_value)
          "Only provides #{category_names(fund_value).to_sentence} support, " \
          "and you are seeking #{category_name(proposal_value)} support"
        end
    end
  end
end
