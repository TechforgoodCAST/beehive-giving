module OrganisationsHelper
  def grant_size_data(funder, years_ago)
    years_ago = years_ago

    average = group_grants_by(funder, :average, years_ago)
    minimum = group_grants_by(funder, :minimum, years_ago)
    maximum = group_grants_by(funder, :maximum, years_ago)
    count = group_grants_by(funder, :count, years_ago)

    merge = [average, minimum, maximum].flat_map(&:keys).uniq
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

  def group_grants_by(funder, calculation, years_ago = 1, metric = :amount_awarded)
    years_ago_result = Date.today.year - years_ago

    funder.grants.where("extract(year FROM approved_on) >= ? AND extract(year from approved_on) <= ?", years_ago_result, Date.today.year).group("DATE_TRUNC('month', approved_on)").calculate(calculation, metric)
  end
end
