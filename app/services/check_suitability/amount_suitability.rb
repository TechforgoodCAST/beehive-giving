class CheckSuitability
  class AmountSuitability < CheckSuitability
    def call(proposal, fund)
      super
      find = fund.amount_awarded_distribution
                 .find { |ar| proposal.total_costs <= ar['end'] }
      {'score' => find ? find['percent'] : 0}
    end
  end
end
