module FundsHelper
  def selected(value, params = {})
    params['eligibility'] == value ? 'selected' : nil
  end

  def redact(fund, field, opts = {})
    placeholder = '**hidden**'

    tokens = fund.name.downcase.split + fund.funder.name.downcase.split
    stop_words = %w[and the fund trust foundation grants charitable]
    final_tokens = tokens - stop_words

    regex = Regexp.new(final_tokens.join('\b|\b'), options: 'i')

    with_placeholder = fund[field].gsub(regex, placeholder)

    scramble = Array.new(rand(5..10)) { [*'a'..'z'].sample }.join

    strip_and_trim(with_placeholder, opts)
      .gsub(placeholder, "<span class='grey redacted'>#{scramble}</span>")
  end

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

  private

    def strip_and_trim(str, opts = {})
      if opts[:trim]
        strip_tags(str).truncate_words(opts[:trim], omission: opts[:omission])
      else
        str
      end
    end
end
