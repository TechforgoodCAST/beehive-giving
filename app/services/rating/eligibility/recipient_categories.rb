module Rating
  module Eligibility
    class RecipientCategories
      include Rating::Base

      private

        def category_name(category_code)
          Recipient::CATEGORIES.values.reduce({}, :merge)[category_code]
        end

        def category_names(category_codes)
          category_codes.map do |category_code|
            Recipient::CATEGORIES.values.reduce({}, :merge)[category_code]
          end
        end

        def eligible(_fund_value, proposal_value)
          "Provides support to #{category_name(proposal_value)}"
        end

        def ineligible(fund_value, proposal_value)
          'Only supports the following types of recipient: ' \
          "#{category_names(fund_value).to_sentence}; you are seeking " \
          "support for #{category_name(proposal_value)}"
        end
    end
  end
end
