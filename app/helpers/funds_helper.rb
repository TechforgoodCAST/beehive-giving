module FundsHelper
  def period(fund = @fund)
    return unless fund.open_data
    content_tag(
      :span,
      fund.period_start.strftime("%b %y'") + ' - ' + fund.period_end.strftime("%b %y'"),
      class: 'year muted'
    )
  end

  def amount_awarded_distribution
    @fund.amount_awarded_distribution.each { |s|
      s['segment'] = "#{to_k(s['start'])} - #{to_k(s['end'])}"
    }.to_json
  end

  def top_award_months(fund = @fund)
    fund.award_month_distribution
        .group_by { |i| i['count'] }
        .sort.last[1]
        .map { |i| Date::MONTHNAMES[i['month']] }
        .to_sentence
  end

  def award_month_distribution
    @fund.award_month_distribution
         .sort_by { |i| i['sort'] }
         .each { |m| m['month'] = Date::MONTHNAMES[m['month']].slice(0, 3) }
         .to_json
  end

  def top_countries(fund = @fund)
    fund.country_distribution
        .group_by { |i| i['count'] }
        .sort.last[1]
        .map { |i| i['name'] }
        .to_sentence
  end

  def country_distribution
    @fund.country_distribution
         .collect { |c| { c['name'] => c['count'] } }
         .reduce({}, :merge)
  end

  private

    def to_k(amount)
      amount.positive? ? "#{amount / 1000}k" : '0'
    end
end
