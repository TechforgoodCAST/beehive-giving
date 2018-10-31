module Check
  module Eligibility
    class RecipientCategories
      include Check::Base

      def call(assessment)
        super
        return unless recipient_categories.any?

        assessment.eligibility_recipient_categories = eligibility
        build_reason(assessment.eligibility_recipient_categories, reasons)
        assessment
      end

      private

        def category
          assessment.recipient.category_code
        end

        def eligibility
          if recipient_categories.include?(category)
            reasons << reason('eligible')
            ELIGIBLE
          else
            reasons << reason('ineligible')
            INELIGIBLE
          end
        end

        def reason(id)
          { id: id, fund_value: recipient_categories, proposal_value: category }
        end

        def recipient_categories
          assessment.fund.recipient_categories
        end
    end
  end
end
