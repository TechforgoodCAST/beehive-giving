module FundsHelper
  def period(fund = @fund, date_format="%b %Y")
    return unless fund.open_data
    if fund.period_start.strftime(date_format) == fund.period_end.strftime(date_format)
      period_desc = fund.period_start.strftime(date_format)
    else
      period_desc = fund.period_start.strftime(date_format) + ' - ' + fund.period_end.strftime(date_format)
    end
    content_tag :span, period_desc
  end

  def amount_awarded_distribution
    @fund.amount_awarded_distribution.each_with_index do |s, i|
      if i == @fund.amount_awarded_distribution.length - 1
        s['segment'] = 'More than ' + number_with_delimiter(s['start'])
      else
        s['segment'] = number_with_delimiter(s['start']) + ' - ' +
                       number_with_delimiter(s['end'] + 1)
      end
    end.to_json
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
end
