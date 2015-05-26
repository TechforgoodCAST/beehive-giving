require 'test_helper'

class RecipientTest < ActiveSupport::TestCase
  setup do
    @recipient = build(:recipient)
  end

  test "recipient with basic details is valid" do
    assert @recipient.valid?
  end

  test "recipient with false details is invalid" do
    assert_not build(:blank_org).valid?
  end

  test "recipient has many users" do
    @recipient.users << build(:user)
    @recipient.users << build(:user)
    assert 2, @recipient.users.size
  end

  test "recipient has many profiles" do
    @recipient.profiles << build(:profile)
    @recipient.profiles << build(:profile)
    assert 2, @recipient.profiles.size
  end

  test "recipient has many grants" do
    @recipient.grants << build(:grant)
    @recipient.grants << build(:grant)
    assert 2, @recipient.grants.size
  end

  test "founded_on before registered_on checked when registered" do
    @recipient.registered = true
    @recipient.founded_on = Date.today - 2.months
    @recipient.registered_on = Date.today - 1.month
    assert @recipient.valid?

    @recipient.founded_on = Date.today - 1.month
    @recipient.registered_on = Date.today - 2.months
    assert_not @recipient.valid?
  end

  test "founded_on befire registered_on is ignored when not registered" do
    @recipient.registered = false
    @recipient.founded_on = Date.today - 1.day
    @recipient.registered_on = Date.today - 7.days
    assert @recipient.valid?
  end

  test "charity number or company number does exist if registered" do
    @recipient.registered = true

    @recipient.company_number = 123
    @recipient.charity_number = 123
    assert @recipient.valid?

    @recipient.company_number = nil
    @recipient.charity_number = 123
    assert @recipient.valid?

    @recipient.company_number = 123
    @recipient.charity_number = nil
    assert @recipient.valid?

    @recipient.company_number = nil
    @recipient.charity_number = nil
    assert_not @recipient.valid?
  end

  test "charity number or company number does not exists if not registered" do
    @recipient.registered = false
    @recipient.save

    assert_equal nil, @recipient.registered_on
    assert_equal nil, @recipient.charity_number
    assert_equal nil, @recipient.company_number
  end
end
