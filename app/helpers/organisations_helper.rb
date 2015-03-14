module OrganisationsHelper
  def grant_size_data(funder)
    average = funder.grants.group("DATE_TRUNC('month', approved_on)").calculate(:average, :amount_awarded)
    minimum = funder.grants.group("DATE_TRUNC('month', approved_on)").calculate(:minimum, :amount_awarded)
    maximum = funder.grants.group("DATE_TRUNC('month', approved_on)").calculate(:maximum, :amount_awarded)

    merge = [average, minimum, maximum].flat_map(&:keys).uniq
    merge = merge.map { |k| {
      approved_on: k.strftime("%Y-%m"),
      average: average[k].to_i,
      minimum: minimum[k],
      maximum: maximum[k]
    } }

    merge.map { |k| Hash[
      :approved_on, k[:approved_on],
      :average, k[:average],
      :minimum, k[:minimum],
      :maximum, k[:maximum]
    ] }
  end
end
