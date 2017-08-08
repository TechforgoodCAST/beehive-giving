class CheckSuitability
  class DurationSuitability < CheckSuitability
    def call(proposal, fund)
      super

      beehive_insight_durations = call_beehive_insight(
        ENV['BEEHIVE_INSIGHT_DURATIONS_ENDPOINT'],
        duration: proposal.funding_duration
      )

      { 'score' => beehive_insight_durations[fund.slug] }
    end

    private

      def call_beehive_insight(endpoint, data)
        options = {
          body: { data: data }.to_json,
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => 'Token token=' + ENV['BEEHIVE_DATA_TOKEN']
          }
        }
        resp = HTTParty.post(endpoint, options)
        JSON.parse(resp.body).to_h
      end
  end
end
