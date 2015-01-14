require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  setup do
    @acme = build(:acme)
  end

  test "organisation with basic details is valid" do
    assert @acme.valid?
  end

  test "organisation with false details is invalid" do
    assert_not build(:blank_org).valid?
  end

  test "has many users" do
    @acme.users << build(:user)
    @acme.users << build(:user)
    assert 2, @acme.users.size
  end

  test "has many profiles" do
    @acme.profiles << build(:profile)
    @acme.profiles << build(:profile)
    assert 2, @acme.profiles.size
  end

  test "has many grants" do
    @acme.grants << build(:grant)
    @acme.grants << build(:grant)
    assert 2, @acme.grants.size
  end

  test "founded before being registered" do
    assert @acme.founded_on < @acme.registered_on
  end
end
