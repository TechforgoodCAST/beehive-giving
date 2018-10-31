module Rating
  module Eligibility
    class Location
      include Rating::Base

      private

        def countries_ineligible(fund_value, proposal_value)
          "Only supports work in #{fund_value&.to_sentence}, " \
          "and you are seeking work in #{proposal_value.to_sentence}"
        end

        def country_outside_area(fund_value, proposal_value)
          out_of_area = (proposal_value - fund_value).to_sentence
          "Work in #{out_of_area} is not supported"
        end

        def district_outside_area(fund_value, proposal_value)
          country_outside_area(fund_value, proposal_value)
        end

        def districts_ineligible(fund_value, proposal_value)
          countries_ineligible(fund_value, proposal_value)
        end

        def geographic_scale_ineligible(fund_value, proposal_value)
          "Only supports #{fund_value&.to_sentence} work, " \
          "and you are seeking #{proposal_value} work"
        end

        def location_eligible(fund_value, proposal_value)
          "Provides support in the area you're looking for"
        end
    end
  end
end
