module FundersHelper
  # TODO: deprecated
  def funding_in_region(district, funder)
    data = []
    year = funder.current_attribute.year
    grant_count = district.ids_by_grant_count('funder', year)
    amount_awarded = district.ids_by_grant_sum('funder', year)
    district.district_funder_ids(funder.current_attribute.year).each do |funder_id|
      data << {
        funder: Funder.find(funder_id).name,
        grant_count: grant_count[funder_id],
        amount_awarded: amount_awarded[funder_id]
      }
    end
    data.sort_by { |hash| hash[:grant_count] }.reverse
  end

  # TODO: deprecated
  def region_difference_count(district, year = @funder.current_attribute.year)
    top_district = district.grant_count_in_region(year).values.first
    current_district = district.grant_count_in_region(year)[district.district]
    less = 1 - (current_district.to_f / top_district.to_f)
    if less.positive?
      safe_join("#{district.district} received <strong>#{number_to_percentage(less * 100, precision: 0)} fewer grants</strong> than <a href='#{funder_district_path(@funder, District.find_by_district(district.amount_awarded_in_region(year).keys.first).slug)}' class='blue'>#{district.amount_awarded_in_region(year).keys.first}</a> which")
    else
      district.grant_count_in_region(year).keys.first
    end
  end

  # TODO: deprecated
  def region_difference_amount(district, year = @funder.current_attribute.year)
    top_district = district.amount_awarded_in_region(year).values.first
    current_district = district.amount_awarded_in_region(year)[district.district]
    less = 1 - (current_district.to_f / top_district.to_f)
    if less.positive?
      safe_join("#{district.district} received <strong>#{number_to_percentage(less * 100, precision: 0)} less funding</strong> than <a href='#{funder_district_path(@funder, District.find_by_district(district.amount_awarded_in_region(year).keys.first).slug)}' class='blue'>#{district.amount_awarded_in_region(year).keys.first}</a> which")
    else
      district.amount_awarded_in_region(year).keys.first
    end
  end

  # TODO: deprecated
  def funding_by_month(funder)
    data = []
    year = funder.current_attribute.year
    grant_count = funder.recent_grants(year).group_by_month(:approved_on, format: '%b').count
    amount_awarded = funder.recent_grants(year).group_by_month(:approved_on, format: '%b').sum(:amount_awarded)
    %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec).each do |month|
      data << {
        month: month,
        grant_count: grant_count[month],
        amount_awarded: amount_awarded[month]
      }
    end
    data
  end

  # TODO: deprecated
  def funding_duration(funder, year = funder.current_attribute.year)
    query = funder.recent_grants(year).where('days_from_start_to_end IS NOT NULL').group(:days_from_start_to_end).count.sort_by { |k, _v| k }.to_h
    amount_awarded = funder.recent_grants(year).where('days_from_start_to_end IS NOT NULL').group(:days_from_start_to_end).sum(:amount_awarded).sort_by { |k, _v| k }.to_h
    max = query.keys.last
    count = (max / 365) + 1
    segments = Array.new(count) { |i| "#{i} to #{i + 1} years" }
    data = []
    segments.each_with_index do |segment, i|
      hash = {}
      query.each do |k, v|
        next unless k > ((i + 1) * 365) - 365 && k <= (i + 1) * 365
        hash[:years] = segment
        hash[:grant_count] = (hash[:grant_count] || 0) + v
        hash[:amount_awarded] = (hash[:amount_awarded] || 0) + amount_awarded[k]
      end
      data << hash
    end
    data.delete_if { |hash| hash == {} }
    data
  end

  # TODO: deprecated
  def funding_frequency_distribution(funder, year = funder.current_attribute.year)
    grants = funder.grants
                   .where('approved_on <= ? AND approved_on >= ?', "#{year}-12-31", "#{year}-01-01")

    range_limit = 475000
    increment = grants.calculate(:maximum, :amount_awarded) < range_limit ? 5 : 25

    range = grants.calculate(:maximum, :amount_awarded) < range_limit ? grants.calculate(:maximum, :amount_awarded) : grants.calculate(:minimum, :amount_awarded) + range_limit
    count = (range / (increment * 1000)) + 1

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
end
