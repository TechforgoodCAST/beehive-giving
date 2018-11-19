module Rating
  module Eligibility
    class Location
      include Rating::Base

      private

        def area_ineligible(fund_value, proposal_value, klass)
          area_names = klass.where(id: proposal_value).pluck(:name)
          "Does not support work in #{area_names.to_sentence}"
        end

        def countries_ineligible(fund_value, proposal_value)
          area_ineligible(fund_value, proposal_value, Country)
        end

        def country_outside_area(fund_value, proposal_value)
          outside_area(fund_value, proposal_value, Country)
        end

        def district_outside_area(fund_value, proposal_value)
          outside_area(fund_value, proposal_value, District)
        end

        def districts_ineligible(fund_value, proposal_value)
          area_ineligible(fund_value, proposal_value, District)
        end

        def geographic_scale_ineligible(fund_value, proposal_value)
          "Only supports #{fund_value&.to_sentence} work, " \
          "and you are seeking #{proposal_value} work"
        end

        def location_eligible(fund_value, proposal_value)
          "Provides support in the area you're looking for"
        end

        def outside_area(fund_value, proposal_value, klass)
          out_of_area = (proposal_value - fund_value)
          area_names = klass.where(id: out_of_area).pluck(:name)
          "Work in #{area_names.to_sentence} is not supported"
        end
    end
  end
end
