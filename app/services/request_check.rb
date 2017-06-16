class RequestCheck  # TODO: refactor
  def initialize(fund, proposal)
    @fund = fund
    @proposal = proposal
    validate_arguments
  end

  def check
    {}.merge!(check_min_amount_awarded)
      .merge!(check_max_amount_awarded)
      .merge!(check_permitted_costs)
  end

  private

    def validate_arguments
      raise 'Invalid Fund object' unless @fund.is_a? Fund
      raise 'Invalid Proposal object' unless @proposal.is_a? Proposal
    end

    def check_min_amount_awarded
      return {} unless @fund.min_amount_awarded_limited
      if @proposal.total_costs < @fund.min_amount_awarded
        mark_ineligible
      else
        {}
      end
    end

    def check_max_amount_awarded
      return {} unless @fund.max_amount_awarded_limited
      if @proposal.total_costs > @fund.max_amount_awarded
        mark_ineligible
      else
        {}
      end
    end

    def check_permitted_costs
      return {} if @proposal.funding_type == 'Other'
      mark_ineligible
    end

    def mark_ineligible
      { 'request' => { 'eligible' => false } }
    end
end