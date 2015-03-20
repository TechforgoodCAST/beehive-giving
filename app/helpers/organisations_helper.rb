module OrganisationsHelper
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
    # grants = {}
    #
    # funder.grants.each do |grant|
    #   grants[:approved_on] = grant.approved_on.strftime("%Y-%m"),
    #   grants[:weeks] = (grant.end_on - grant.start_on).to_i / 52
    # end

    # grants = funder.grants.map do |g| Hash[
    #   :approved_on, g.approved_on.strftime("%Y-%m"),
    #   :weeks, (g.end_on - g.start_on).to_i / 52
    #   ]
    # end

    # grants = Grant.all.map do |g| Hash[
    #   "approved_on", g.approved_on.strftime("%Y-%m"),
    #   "weeks", (g.end_on - g.start_on).to_i / 52
    #   ]
    # end
    #
    grants = Grant.all.map do |g| Hash[
      # "approved_on".to_sym, g.approved_on.strftime("%Y-%m"),
      "weeks".to_sym, (g.end_on - g.start_on).to_i / 52
      ]
    end

    # grants.map do |hash|
    #   hash.select do |key, value|
    #     [:approved_on, :weeks].include? key
    #   end
    # end
    # grants = grants.reduce Hash.new, :deep_merge
    # b = grants.group_by { |h| h[:approved_on] }.values.select { |a| a.size > 1 }.flatten

    # grants = Hash[grants.map(&:values).map(&:flatten)]

    # [{"approved_on":"2014-02","average_weeks":15},{"approved_on":"2013-10","average_weeks":14}]

    # somme_enum.inject({}) do |hash, element|
    #   hash[element.foo] = element.bar
    #   hash
    #  end

    years_ago = years_ago

    years_ago_result = Date.today.year - years_ago

    Grant.all.where("extract(year FROM approved_on) >= ? AND extract(year from approved_on) <= ?", 3, Date.today.year).group("DATE_TRUNC('month', approved_on)")

    # g = Grant.all.inject({}){ |hash, (grant, k)| hash.merge( grant.approved_on => grant.approved_on)  }

    # grants.each { |hash, key| hash[:weeks] }

    # hash = grants.each { |hash, key| hash[:weeks] }
    average = group_grants_by(funder, :average, years_ago, grants[0][:weeks] )


    end_on = group_grants_by(funder, :count, years_ago, :end_on )
    # average = group_grants_by(funder, :count, years_ago, (start_on - end_on) )

    # minimum = group_grants_by(funder, :minimum, years_ago, grants[1][:weeks])
    # maximum = group_grants_by(funder, :maximum, years_ago, grants[3][:weeks])
    # count = group_grants_by(funder, :count, years_ago)

    merge = [average].flat_map(&:keys).uniq
    merge = merge.map { |v| {
      approved_on: v.strftime("%Y-%m"),
      average: average[v].to_i,
      # minimum: minimum[v],
      # maximum: maximum[v],
      # count: count[v]
    } }

    merge.map { |v| Hash[
      :approved_on, v[:approved_on],
      :average, v[:average],
      # :minimum, v[:minimum],
      # :maximum, v[:maximum],
      # :count, v[:count]
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

  def group_grants_by(funder, calculation, years_ago = 1, metric = :amount_awarded)
    years_ago_result = Date.today.year - years_ago

    funder.grants.where("extract(year FROM approved_on) >= ? AND extract(year from approved_on) <= ?", years_ago_result, Date.today.year).group("DATE_TRUNC('month', approved_on)").calculate(calculation, metric)
  end
end
