module Check
  module Suitability
    class Duration
      include Check::Base

      def call(proposal, fund)
        validate_call proposal, fund
        response = proposal.beehive_insight_durations
        { 'score' => response.key?(fund.slug) ? response[fund.slug].to_f : 0.0 }
      end
    end
  end
end
