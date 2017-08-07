class CheckSuitability
  class LocationSuitability < CheckSuitability
    def call(proposal, fund)
      super
      result = {}
      result = match_anywhere(fund, proposal, result)
      result = match_national(fund, proposal, result)
      result = match_districts(fund, proposal, result)
      result = match_ineligible(fund, proposal, result)
      result
    end

    private

      def match_anywhere(fund, proposal, result = {})
        if fund.geographic_scale_limited
          result = { 'score' => -1, 'reason' => 'overlap' }
        else
          result = { 'score' => 1, 'reason' => 'anywhere' }
        end
        result
      end

      def match_districts(fund, proposal, result = {})
        if proposal.affect_geo != 2 && fund.geographic_scale_limited && !fund.national
          match = match_result(fund.district_ids, proposal.district_ids)
          result = { 'score' => match[0], 'reason' => match[1] }
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

      def match_national(fund, proposal, result = {})
        if fund.national
          if proposal.affect_geo == 2
            result = { 'score' => 1, 'reason' => 'national' }
          else
            result = { 'score' => -1, 'reason' => 'ineligible' }
          end
        end
        result
      end

      def match_ineligible(fund, proposal, result = {})
        unless proposal.eligibility.fetch(fund.slug, {}).fetch("location", {}).fetch("eligible", true)
          result = { 'score' => -1, 'reason' => 'ineligible' }
        end
        result
      end
  end
end
