require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  test "organisation with basic details is valid" do
    assert build(:acme).valid?
  end

  test "organisation with false details is invalid" do
    assert_not build(:blank_org).valid?
  end

  test "doesn't allow duplicate emails for different orgs" do
    create(:acme)
    assert_not build(:acme).valid?
  end

  test "has many profiles" do
    acme = build(:acme)
    acme.profiles << build(:profile)
    acme.profiles << build(:profile)
    assert 2, acme.profiles.size
  end
end
