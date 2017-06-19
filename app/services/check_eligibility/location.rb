class CheckEligibility
  class Location < CheckEligibility
    def call(proposal, fund)
      super
      return eligible false if countries_ineligible?(proposal, fund)
      return eligible true  if proposal.affect_geo == 2
      return eligible false if national_ineligible?(proposal, fund)
      return eligible false if districts_ineligible?(proposal, fund)
      eligible true
    end

    private

      def countries_ineligible?(proposal, fund)
        (proposal.country_ids & fund.country_ids).length.zero?
      end

      def national_ineligible?(_, fund)
        fund.geographic_scale_limited && fund.national
      end

      def districts_ineligible?(proposal, fund)
        return false unless fund.geographic_scale_limited && !fund.national
        (proposal.district_ids & fund.district_ids).length.zero?
      end

      def eligible(bool)
        { 'eligible' => bool }
      end
  end
end
