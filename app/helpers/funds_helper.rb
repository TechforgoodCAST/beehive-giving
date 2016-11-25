module FundsHelper

  def amount_awarded_distribution
    @fund.amount_awarded_distribution.each { |s|
      s['segment'] = "#{to_k(s['start'])} - #{to_k(s['end'])}"
    }.to_json
  end

  def award_month_distribution
    @fund.award_month_distribution
      .sort_by { |i| i['sort'] }
      .each { |m| m['month'] = Date::MONTHNAMES[m['month']].slice(0,3) }
      .to_json
  end

  def country_distribution
    @fund.country_distribution
      .collect { |c| { c['name'] => c['count'] } }
      .reduce({}, :merge)
  end


  private

    def to_k(amount)
      amount > 0 ? "#{amount / 1000}k" : '0'
    end

end
