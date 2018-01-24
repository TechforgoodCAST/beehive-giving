module Check
  module Eligibility
    class Location
      include Check::Base

      def call(assessment)
        super
        assessment.eligibility_location = eligibility
        assessment
      end

      private

        def eligibility
          return INELIGIBLE if countries_ineligible?
          return INELIGIBLE if national_ineligible?
          return INELIGIBLE if local_ineligible?
          ELIGIBLE
        end

        def geographic_scale_limited?
          assessment.fund.geographic_scale_limited?
        end

        def national?
          assessment.fund.national?
        end

        def proposal_national?
          assessment.proposal.affect_geo == 2
        end

        def fund_geo_ids(geo)
          assessment.fund.geo_area.send(geo.pluralize).pluck(:id)
        end

        def proposal_geo_ids(geo)
          assessment.proposal.send("#{geo}_ids")
        end

        def ineligible?(geo)
          (proposal_geo_ids(geo) & fund_geo_ids(geo)).empty?
        end

        def countries_ineligible?
          ineligible?('country')
        end

        def national_ineligible?
          return false if proposal_national?
          geographic_scale_limited? && national?
        end

        def local_ineligible?
          return false unless geographic_scale_limited? && !national?
          ineligible?('district')
        end
    end
  end
end
