class CheckSuitability
  class DurationSuitability < CheckSuitability
    def call(proposal, fund)
      super
      response = proposal.beehive_insight_durations
      { 'score' => response.key?(fund.slug) ? response[fund.slug].to_f : 0.0 }
    end
  end
end
