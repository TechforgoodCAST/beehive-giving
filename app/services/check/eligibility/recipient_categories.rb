module Check
  module Eligibility
    class RecipientCategories
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_recipient_categories = eligibility
        assessment.reasons[self.class.to_s] = build_reason(
          assessment.eligibility_recipient_categories, reasons
        )
        assessment
      end

      private

        def category
          assessment.recipient.category_code
        end

        def eligibility
          if recipient_categories.include?(category)
            ELIGIBLE
          else
            reasons << 'Only supports the following types of recipient: ' +
                       supported_categories
            INELIGIBLE
          end
        end

        def recipient_categories
          assessment.fund.recipient_categories
        end

        def supported_categories
          categories = Recipient::CATEGORIES.values.reduce({}, :merge)
          recipient_categories.map { |code| categories[code] }.to_sentence
        end
    end
  end
end
