class CheckSuitability
  class AmountSuitability < CheckSuitability
    def call(proposal, fund)
      super
      find = fund.amount_awarded_distribution
                 .find { |segment| proposal.total_costs <= segment['end'] }
      { 'score' => find ? find['percent'] : 0 }
    end
  end
end
