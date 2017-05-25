class LocationMatch < Recommender
  def match(eligibility = {})
    updates = eligibility.clone
    updates.except_nested_key('location')
           .delete_if { |_, v| v.empty? }
           .deep_merge(check_country)
           .deep_merge(check_national)
           .deep_merge(check_districts)
  end

  private

    def check_country
      result = {}
      all_fund_slugs = @funds.pluck(:slug)
      matched_fund_slugs = @funds.joins(:countries)
                                 .where('countries.id': @proposal.country_ids)
                                 .pluck(:slug)
      (all_fund_slugs - matched_fund_slugs).each do |slug|
        mark_ineligible result, slug
      end
      result
    end

    def check_national
      result = {}
      return result if @proposal.affect_geo == 2
      @funds.where(geographic_scale_limited: true, national: true)
            .pluck(:slug)
            .each do |slug|
        mark_ineligible result, slug
      end
      result
    end

    def check_districts
      result = {}
      @funds.where(geographic_scale_limited: true, national: false)
            .left_outer_joins(:districts)
            .select(:id, :slug, 'array_agg(districts.id) AS fund_district_ids')
            .group(:id, :slug).each do |fund|
        if (@proposal.district_ids & fund.fund_district_ids).count.zero?
          mark_ineligible result, fund.slug
        end
      end
      result
    end

    def mark_ineligible(hash, key)
      hash[key] = { 'location' => false }
    end
end
