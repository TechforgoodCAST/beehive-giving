module Check
  module Suitability
    class OrgType
      include Check::Base

      def call(proposal, fund)
        validate_call proposal, fund

        return { 'error' => 'No data available' } unless fund.open_data?

        org_type_score = 0

        if fund.org_type_distribution?
          org_type_score = parse_distribution(
            fund.org_type_distribution,
            ORG_TYPES[proposal.recipient.org_type + 1][0]
          )
        end

        if org_type_score.positive?
          org_type_score += parse_distribution(
            fund.income_distribution,
            Recipient::INCOME_BANDS[proposal.recipient.income_band][0]
          )
        end

        { 'score' => org_type_score.to_f }
      end

      private

        def parse_distribution(data, comparison)
          data
            .sort_by { |i| i['position'] }
            .select { |i| i['label'] == comparison unless i['label'] == 'Unknown' }
            .first.to_h.fetch('percent', 0)
        end
    end
  end
end
