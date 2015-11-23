module OrganisationsHelper

  def funding_by_month(funder)
    data = []
    grants = funder.recent_grants.group_by_month(:approved_on, format: '%b').count
    %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec].each do |month|
      data << {
        month: month,
        grant_count: grants[month]
      }
    end
    data
  end

  # refactor dry
  def amount_by_month(funder)
    data = []
    grants = funder.recent_grants.group_by_month(:approved_on, format: '%b').calculate(:sum, :amount_awarded)
    %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec].each do |month|
      data << {
        month: month,
        amount_awarded: grants[month]
      }
    end
    data
  end

  def funding_by_regions(funder)
    data = []
    funder.districts_by_year.group(:district).count.sort_by {|k, v| v}.reverse.to_h.each do |k, v|
      data << {
        region: k,
        grant_count: v
      }
    end
    data
  end

  def funding_frequency_distribution(funder, year)
    # if @funding_stream == 'All'
    grants = funder.grants
      .where("approved_on <= ? AND approved_on >= ?", "#{year}-12-31", "#{year}-01-01")
    # else
    #   grants = funder.grants
    #     .where("approved_on < ? AND approved_on >= ?", "#{year + 1}-01-01", "#{year}-01-01")
    #     .where("funding_stream = ?", @funding_stream)
    # end

    range_limit = 475000
    increment = grants.calculate(:maximum, :amount_awarded) < range_limit ? 5 : 25

    range = grants.calculate(:maximum, :amount_awarded) < range_limit ? grants.calculate(:maximum, :amount_awarded) : grants.calculate(:minimum, :amount_awarded) + range_limit
    count = (range / (increment * 1000)) + 1
    max = grants.calculate(:maximum, :amount_awarded) + (increment * 1000)

    data = []
    count.times do |i|
      start_amount = i * (increment * 1000)
      end_amount = (i * (increment * 1000)) + (increment * 1000)

      data << {
        target: "#{number_to_currency(i * increment, unit: '£', precision: 0)}k - #{number_to_currency(i * increment + increment, unit: '£', precision: 0)}k",
        grant_count: grants.where('amount_awarded >= ? AND amount_awarded < ?', start_amount, end_amount).count
      }
    end

    unless grants.calculate(:maximum, :amount_awarded) < range_limit
      data << {
        target: "Above #{number_to_currency(count * increment, unit: '£', precision: 0)}k",
        grant_count: grants.where('amount_awarded >= ? AND amount_awarded <= ?', (count * increment) * 1000, grants.calculate(:maximum, :amount_awarded)).count
      }
    end

    data
  end

  def multiple_funding_frequency_distribution(funders)
    increment = 5
    data = []

    max = 45000
    count = (max / (increment * 1000)) + 1

    count.times do |i|
      start_amount = i * (increment * 1000)
      end_amount = (i * (increment * 1000)) + (increment * 1000)

      hash = {
        target: "#{number_to_currency(i * increment, unit: '£', precision: 0)}k - #{number_to_currency(i * increment + increment, unit: '£', precision: 0)}k"
      }

      funders.each_with_index do |funder, f|
        hash[:"funder#{f+1}"] = funder.grants.where('approved_on < ? AND approved_on >= ?', '2015-01-01', '2014-01-01').where('amount_awarded >= ? AND amount_awarded < ?', start_amount, end_amount).count
      end

      data << hash
    end

    data
  end

  def compare_funder(funder, funder2, years_ago)
    funder1 = group_grants_by(funder, :count, years_ago)
    funder2 = group_grants_by(funder2, :count, years_ago)

    merge = [funder1, funder2].flat_map(&:keys).uniq
    merge = merge.map { |v| {
      approved_on: v.strftime("%Y-%m"),
      funder1: funder1[v] || 0,
      funder2: funder2[v] || 0
    } }

    merge.map { |v| Hash[
      :approved_on, v[:approved_on],
      :funder1, v[:funder1],
      :funder2, v[:funder2]
    ] }
  end

end
