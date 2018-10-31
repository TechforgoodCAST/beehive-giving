module Check
  module Eligibility
    class Location
      include Check::Base

      def call(assessment)
        super

        # TODO: return if not needed

        assessment.eligibility_location = eligibility
        build_reason(assessment.eligibility_location, reasons)
        assessment
      end

      private

        def countries_ineligible
          reasons << {
            id: 'countries_ineligible',
            fund_value: fund_geo_ids('country'),
            proposal_value: proposal_geo_ids('country')
          }
          INELIGIBLE
        end

        def districts_ineligible
          reasons << {
            id: 'districts_ineligible',
            fund_value: fund_geo_ids('district'),
            proposal_value: proposal_geo_ids('district')
          }
          INELIGIBLE
        end

        def eligibility
          if permitted_geographic_scales.include?(geographic_scale)

            if proposal_area_limited?
              return countries_ineligible if ineligible?('country')

              if local_or_regional?
                return districts_ineligible if ineligible?('district')
              end
            end

            reasons << { id: 'location_eligible' }
            ELIGIBLE
          else
            reasons << {
              id: 'geographic_scale_ineligible',
              fund_value: permitted_geographic_scales,
              proposal_value: geographic_scale
            }
            INELIGIBLE
          end
        end

        def fund_geo_ids(geo)
          assessment.fund.geo_area.send(geo.pluralize).pluck(:id)
        end

        def geographic_scale
          assessment.proposal.geographic_scale
        end

        def ineligible?(geo)
          overlap = (proposal_geo_ids(geo) & fund_geo_ids(geo))
          if proposal_all_in_area?
            if proposal_geo_ids(geo).size > overlap.size
              reasons << {
                id: "#{geo}_outside_area",
                fund_value: overlap,
                proposal_value: proposal_geo_ids(geo)
              }
              true
            else
              false
            end
          else
            overlap.empty?
          end
        end

        def local_or_regional?
          %w[local regional].include?(assessment.proposal.geographic_scale)
        end

        def permitted_geographic_scales
          assessment.fund.proposal_permitted_geographic_scales
        end

        def proposal_all_in_area?
          assessment.fund.proposal_all_in_area?
        end

        def proposal_area_limited?
          assessment.fund.proposal_area_limited?
        end

        def proposal_geo_ids(geo)
          assessment.proposal.send("#{geo}_ids")
        end
    end
  end
end
