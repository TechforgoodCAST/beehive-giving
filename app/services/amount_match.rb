class AmountMatch < Recommender
  def match
    result = {}
    @funds.each do |fund|
      find = fund.amount_awarded_distribution
                 .find { |ar| @proposal.total_costs <= ar['end'] }
      result[fund.slug] = find ? find['percent'] : 0
    end
    result
  end
end
