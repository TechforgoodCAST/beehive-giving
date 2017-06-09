class AmountMatch < Recommender
  def match
    result = {}
    @funds.each do |fund|
      result[fund.slug] = fund.amount_awarded_distribution.find do |ar|
        @proposal.total_costs <= ar['end']
      end['percent']
    end
    result
  end
end
