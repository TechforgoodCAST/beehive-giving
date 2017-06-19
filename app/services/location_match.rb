class LocationMatch < Recommender
  def match(recommendation = {})
    updates = recommendation.clone
    updates.deep_merge(match_anywhere)
           .deep_merge(match_national)
           .deep_merge(match_districts)
           .deep_merge(match_ineligible)
  end

  private

    def match_anywhere
      result = {}
      @funds.pluck(:slug, :geographic_scale_limited).each do |slug, local_fund|
        if local_fund
          result[slug] = { 'location' => { 'score' => -1, 'reason' => 'overlap' } }
        else
          result[slug] = { 'location' => { 'score' => 1, 'reason' => 'anywhere' } }
        end
      end
      result
    end

    def match_districts
      result = {}
      return result if @proposal.affect_geo == 2
      fund_district_ids.each do |fund|
        match = match_result(fund.fund_district_ids, @proposal.district_ids)
        result[fund.slug] = {
          'location' => { 'score' => match[0], 'reason' => match[1] }
        }
      end
      result
    end

    def match_result(f, p)
      return [1, 'exact'] if exact_match(f, p)
      return [0, 'intersect'] if intersect_match(f, p)
      return [1, 'partial'] if partial_match(f, p)
      return [-1, 'overlap'] if overlap_match(f, p)
    end

    def exact_match(f, p)
      f == p
    end

    def intersect_match(f, p)
      (f - p).count.positive? && (p - f).count.positive?
    end

    def partial_match(f, p)
      (p - f).count.zero?
    end

    def overlap_match(f, p)
      (f - p).count.zero? && (p - f).count.positive?
    end

    def match_national
      result = {}
      @funds.pluck(:slug, :geographic_scale_limited, :national)
            .select { |i| i[2] }.pluck(0).each do |slug|
        if @proposal.affect_geo == 2
          result[slug] = { 'location' => { 'score' => 1, 'reason' => 'national' } }
        else
          result[slug] = { 'location' => { 'score' => -1, 'reason' => 'ineligible' } }
        end
      end
      result
    end

    def match_ineligible(eligibility = @proposal.eligibility)
      result = {}
      eligibility.reject { |_, v| v.value?(true) }
                 .keys.each do |slug|
        result[slug] = { 'location' => { 'score' => -1, 'reason' => 'ineligible' } }
      end
      result
    end

    def fund_district_ids
      @funds.where(geographic_scale_limited: true, national: false)
            .left_outer_joins(:districts)
            .select(:id, :slug, 'array_agg(districts.id) AS fund_district_ids')
            .group(:id, :slug)
    end

    def mark_ineligible(hash, key)
      hash[key] = { 'location' => { 'eligible' => false } }
    end
end
