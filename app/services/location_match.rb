class LocationMatch
  def initialize(funds, proposal)
    @funds = funds
    @proposal = proposal
    validate_arguments
  end

  def match(eligibility = {})
    updates = eligibility.clone
    updates.delete_if { |_, v| v['reason'] == 'location' }
           .merge(check_country)
           .merge(check_national)
           .merge(check_districts)
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
      return result unless @proposal.affect_geo == 2
      @funds.where(geographic_scale: 2, geographic_scale_limited: true)
            .pluck(:slug)
            .each do |slug|
        mark_ineligible result, slug
      end
      result
    end

    def check_districts
      result = {}
      @funds.where(geographic_scale_limited: true)
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
      hash[key] = { 'eligible' => false, 'reason' => 'location' }
    end

    def validate_arguments
      raise 'Invalid Fund::ActiveRecord_Relation' unless
        @funds.instance_of? Fund::ActiveRecord_Relation
      raise 'Invalid Proposal object' unless @proposal.instance_of? Proposal
    end
end
