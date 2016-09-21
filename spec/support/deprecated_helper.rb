class DeprecatedHelper

  include FactoryGirl::Syntax::Methods

  def initialize
    @age_groups    = AgeGroup.all
    @beneficiaries = Beneficiary.all
    @countries     = Country.all
    @districts     = District.all
    @recipient     = Recipient.last
  end

  def create_funder_attributes(num: 2)
    Array.new(num) do |i|
      create(:funder_attribute,
        funder: create(:funder),
        countries: @countries,
        districts: @districts
      )
    end
    self
  end

  def create_profiles(num: 2)
    Array.new(num) do |i|
      create(:current_profile,
        year: Date.today.year - i,
        organisation: @recipient,
        countries: @countries,
        districts: @districts,
        age_groups: @age_groups,
        beneficiaries: @beneficiaries
      )
    end
    self
  end

  def create_grants(num: 2)
    create_list(:grant, num,
      funder: create(:funder),
      countries: @countries,
      districts: @districts
    )
    self
  end

end
