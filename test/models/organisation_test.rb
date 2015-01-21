require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase
  setup do
    @recipient = build(:recipient)
  end

  test "organisation with basic details is valid" do
    assert @recipient.valid?
  end

  test "organisation with false details is invalid" do
    assert_not build(:blank_org).valid?
  end

  test "has many users" do
    @recipient.users << build(:user)
    @recipient.users << build(:user)
    assert 2, @recipient.users.size
  end

  test "has many profiles" do
    @recipient.profiles << build(:profile)
    @recipient.profiles << build(:profile)
    assert 2, @recipient.profiles.size
  end

  test "has many grants" do
    @recipient.grants << build(:grant)
    @recipient.grants << build(:grant)
    assert 2, @recipient.grants.size
  end

  test "founded before being registered" do
    assert @recipient.founded_on < @recipient.registered_on
  end
end
