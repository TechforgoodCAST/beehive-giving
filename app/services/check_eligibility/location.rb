class CheckEligibility
  class Location < Setup
    def call(fund)
      return eligible false if counties_ineligible? fund
      return eligible true  if @proposal.affect_geo == 2
      return eligible false if national_ineligible?  fund
      return eligible false if districts_ineligible? fund
      eligible true
    end

    private

      def counties_ineligible?(fund)
        (@proposal.country_ids & fund.country_ids).length.zero?
      end

      def national_ineligible?(fund)
        fund.geographic_scale_limited && fund.national
      end

      def districts_ineligible?(fund)
        return false unless fund.geographic_scale_limited && !fund.national
        (@proposal.district_ids & fund.district_ids).length.zero?
      end

      def eligible(bool)
        { 'eligible' => bool }
      end
  end
end
