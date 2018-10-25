module Check
  module Eligibility
    class Location
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_location = eligibility
        build_reason(assessment.eligibility_location, reasons)
        assessment
      end

      private

        def countries_ineligible
          # TODO: more descriptive message
          reasons << "Does not support work in the countries you're seeking"
          INELIGIBLE
        end

        def districts_ineligible
          # TODO: more descriptive message
          reasons << "Does not support work in the areas you're seeking"
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

            ELIGIBLE
          else
            reasons << "Only supports #{permitted_geographic_scales.to_sentence} work"
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
              reasons << 'Some of your work takes place outside of the permitted areas'
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
