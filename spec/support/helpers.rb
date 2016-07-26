module Helpers

  def seed_test_db
    @countries       = create_list(:country, 2)
    @uk_districts    = create_list(:district, 3, country: @countries.first)
    @kenya_districts = create_list(:kenya_district, 3, country: @countries.last)
    @districts       = @uk_districts + @kenya_districts
  end

  def basic_setup
    seed_test_db
    @beneficiaries = FactoryGirl.create_list(:beneficiary, 2) # TODO: refactor
    @age_groups = FactoryGirl.create_list(:age_group, 2) # TODO: refactor

    @funding_types = create_list(:funding_type, FundingType::FUNDING_TYPE.count)

    @recipient = create(:recipient)
    @user = create(:user, organisation: @recipient)

    @funders = create_list(:funder, 4)
    # @funders.each do |funder|
    #   create_list(:grants, 2, funder: funder, recipient: @recipient,
    #                countries: @countries, districts: @districts
    #              )
    #   create(:funder_attribute, funder: funder,
    #           beneficiaries: @beneficiaries,
    #           age_groups: @age_groups,
    #           countries: @countries,
    #           districts: @districts,
    #           funding_types: @funding_types
    #         )
    # end
  end

end
