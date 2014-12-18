require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  setup do
    @acme = create(:acme)
    @profile = build(:profile, organisation: @acme)
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
    create(:profile, organisation: @acme)
    assert_not @profile.valid?
  end

  test "allows duplicate years for the different orgs" do
    @profile =  build(:profile, organisation: create(:organisation, n: 2))
    assert @profile.valid?
  end
end
