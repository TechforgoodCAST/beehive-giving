class LocationMatch
  def initialize(funds, proposal)
    @funds = funds
    @proposal = proposal
    validate_arguments
  end

  def match(eligibility = {})
    eligibility = check_country(eligibility)
    check_national(eligibility)
  end

  private

    def check_country(eligibility)
      all_fund_slugs = @funds.pluck(:slug)
      matched_fund_slugs = @funds.joins(:countries)
                                 .where('countries.id': @proposal.country_ids)
                                 .pluck(:slug)
      ineligible_fund_slugs = all_fund_slugs - matched_fund_slugs
      ineligible_fund_slugs.each do |slug|
        eligibility[slug] = { eligible: false, reason: 'location' }
      end
      eligibility
    end

    def check_national(eligibility)
      matched_fund_slugs = @funds
                           .where(geographic_scale: 2, geographic_scale_limited: true)
                           .pluck(:slug)
      return eligibility unless @proposal.affect_geo == 2
      matched_fund_slugs.each do |slug|
        eligibility[slug] = { eligible: false, reason: 'location' }
      end
      eligibility
    end

    def validate_arguments
      raise 'Invalid Fund::ActiveRecord_Relation' unless
        @funds.instance_of? Fund::ActiveRecord_Relation
      raise 'No funds supplied' if @funds.empty?
      raise 'Invalid Proposal object' unless @proposal.instance_of? Proposal
    end
end
