module OrganisationsHelper

  def group_grants_by(funder, calculation, years_ago = 1, metric = :amount_awarded)
    years_ago_result = Date.today.year - years_ago

    funder.grants.where("extract(year FROM approved_on) >= ? AND extract(year from approved_on) <= ?", years_ago_result, Date.today.year).group("DATE_TRUNC('month', approved_on)").calculate(calculation, metric)
  end

  def grant_size_data(funder, years_ago)
    years_ago = years_ago

    average = group_grants_by(funder, :average, years_ago)
    minimum = group_grants_by(funder, :minimum, years_ago)
    maximum = group_grants_by(funder, :maximum, years_ago)
    count = group_grants_by(funder, :count, years_ago)

    merge = [average, minimum, maximum, count].flat_map(&:keys).uniq
    merge = merge.map { |v| {
      approved_on: v.strftime("%Y-%m"),
      average: average[v].to_i,
      minimum: minimum[v],
      maximum: maximum[v],
      count: count[v]
    } }

    merge.map { |v| Hash[
      :approved_on, v[:approved_on],
      :average, v[:average],
      :minimum, v[:minimum],
      :maximum, v[:maximum],
      :count, v[:count]
    ] }
  end

  def grant_duration_data(funder, years_ago)
    years_ago = years_ago

    average = group_grants_by(funder, :average, years_ago, :days_from_start_to_end )
    minimum = group_grants_by(funder, :minimum, years_ago, :days_from_start_to_end)
    maximum = group_grants_by(funder, :maximum, years_ago, :days_from_start_to_end)

    merge = [average].flat_map(&:keys).uniq
    merge = merge.map { |v| {
      approved_on: v.strftime("%Y-%m"),
      average: (average[v].to_i / 30.4368).to_i,
      minimum: (minimum[v] / 30.4368).to_i,
      maximum: (maximum[v] / 30.4368).to_i
    } }

    merge.map { |v| Hash[
      :approved_on, v[:approved_on],
      :average, v[:average],
      :minimum, v[:minimum],
      :maximum, v[:maximum]
    ] }
  end

  def compare_funder(funder, funder2, years_ago)
    years_ago = years_ago

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
