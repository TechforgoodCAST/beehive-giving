module Rating
  module Eligibility
    class Location
      include Rating::Base

      def title
        'Location'
      end

      protected

        def state
          assessment&.eligibility_location
        end

      private

        def eligible_message
          return unless assessment
          "Awards funds in <strong>#{assessment.fund.geo_area.name}</strong>."
        end

        def ineligible_message
          return unless assessment
          'You are ineligible because of the ' \
          "#{assessment.fund.geo_area.name} of your proposal."
        end
    end
  end
end
