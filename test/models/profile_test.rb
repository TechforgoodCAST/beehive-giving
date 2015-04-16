require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  setup do
    @recipient = create(:recipient)
    @profile = build(:profile, organisation: @recipient)
    @country = create(:country)
    @district = build(:district, country: @country)
  end

  test "a profile belongs to an organisation" do
    assert_equal 'ACME', @profile.organisation.name
  end

  test "a valid profile" do
    assert @profile.valid?
  end

  test "only positive numbers are allowed" do
    @profile.min_age = -10
    assert_not @profile.valid?
  end

  test "doesn't allow duplicates for the same org/year" do
    create(:profile, organisation: @recipient)
    assert_not @profile.valid?
  end

  test "allows duplicate years for the different orgs" do
    @profile =  build(:profile, organisation: create(:organisation, n: 1))
    assert @profile.valid?
  end

  test "a district belongs to a country" do
    assert @district.country
  end

  test "doesn't allow profile before year of founding" do
    @profile.year = 2013
    assert_not @profile.valid?
  end
end
