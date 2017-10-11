module Check
  module Suitability
    class Location
      include Check::Base

      def call(proposal, fund)
        validate_call proposal, fund
        result = {}
        result.merge(match_anywhere(fund, proposal))
              .merge(match_national(fund, proposal))
              .merge(match_districts(fund, proposal))
              .merge(match_ineligible(fund, proposal))
      end

      private

        def match_anywhere(fund, _proposal)
          if fund.geographic_scale_limited
            { 'score' => 0, 'reason' => 'overlap' }
          else
            { 'score' => 1, 'reason' => 'anywhere' }
          end
        end

        def match_national(fund, proposal)
          return {} unless fund.national?
          if proposal.affect_geo == 2
            { 'score' => 1, 'reason' => 'national' }
          else
            { 'score' => 0, 'reason' => 'ineligible' }
          end
        end

        def match_districts(fund, proposal)
          return {} unless proposal.affect_geo != 2 &&
                           (fund.geographic_scale_limited && !fund.national)
          match = match_result(fund.geo_area.districts.pluck(:id), proposal.district_ids)
          { 'score' => match[0], 'reason' => match[1] }
        end

        def match_ineligible(fund, proposal)
          return {} if proposal.eligibility
                               .fetch(fund.slug, {})
                               .fetch('location', {}).fetch('eligible', true)
          { 'score' => 0, 'reason' => 'ineligible' }
        end

        def match_result(f, p)
          return [1, 'exact'] if exact_match(f, p)
          return [0, 'intersect'] if intersect_match(f, p)
          return [1, 'partial'] if partial_match(f, p)
          [0, 'overlap'] if overlap_match(f, p)
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
    end
  end
end
