module Check
  module Suitability
    class Amount
      include Check::Base

      def call(proposal, fund)
        validate_call proposal, fund
        return { 'error' => 'No data available' } unless fund.open_data?
        find = fund.amount_awarded_distribution
                   .find { |segment| proposal.total_costs <= segment['end'] }
        { 'score' => find ? find['percent'] : 0 }
      end
    end
  end
end
