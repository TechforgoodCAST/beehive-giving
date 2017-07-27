class CheckEligibility
  class Amount < CheckEligibility
    def call(proposal, fund)
      super
      return eligible false if (fund.min_amount_awarded_limited && proposal.total_costs < fund.min_amount_awarded)
      return eligible false if (fund.max_amount_awarded_limited && proposal.total_costs > fund.max_amount_awarded)
      eligible true
    end

    private

      def eligible(bool)
        { 'eligible' => bool }
      end
  end
end
