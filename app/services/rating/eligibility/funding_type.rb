module Rating
  module Eligibility
    class FundingType
      include Rating::Base

      def title
        'Type of funding'
      end

      protected

        def state
          assessment&.eligibility_funding_type
        end

      private

        def eligible_message # TODO: refactor!
          return unless assessment
          costs = assessment.fund.permitted_costs.reject(&:zero?)
                      .map { |c| FUNDING_TYPES[c][0].split.first.downcase }
                      .to_sentence(
                        two_words_connector: ' & ', last_word_connector: ' & '
                      )
          "Awards <strong>#{costs}</strong> grants." if costs.present?
        end

        def ineligible_message # TODO: refactor!
          return unless assessment
          funding_type = FUNDING_TYPES[assessment.proposal.funding_type][0]
                           .split[0].downcase
          "Does not award <strong>#{funding_type}</strong> grants."
        end
    end
  end
end
