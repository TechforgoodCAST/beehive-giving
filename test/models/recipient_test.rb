require 'test_helper'

class RecipientTest < ActiveSupport::TestCase

  setup do
    3.times { |i| create(:funder, :active_on_beehive => true) }
    @recipient = create(:recipient)
    @recipient.initial_recommendation
  end

  test "recipient has initial recommendations" do
    assert_equal 3, @recipient.recommendations.count
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

  test "recipient has many recommendations" do
    @recipient.recommendations << build(:recommendation)
    @recipient.recommendations << build(:recommendation)
    assert 2, @recipient.recommendations.size
  end

  test "charity number or company number does exist if registered organisation" do
    case @recipient.org_type
    when 1
      @recipient.charity_number = 123
      assert_equal nil, @recipient.company_number
      assert @recipient.valid?
    when 2
      @recipient.company_number = 123
      assert_equal nil, @recipient.charity_number
      assert @recipient.valid?
    when 3
      @recipient.company_number = 123
      @recipient.charity_number = 123
      assert @recipient.valid?
    else
      assert_equal nil, @recipient.company_number
      assert_equal nil, @recipient.charity_number
      assert_equal nil, @recipient.registered_on
      assert_not @recipient.valid?
    end
  end

  test "geocoded if postal_code" do
    @recipient.charity_number = '1161998'
    @recipient.get_charity_data
    @recipient.save
    assert_equal true, @recipient.postal_code.present?
    assert_equal false, @recipient.street_address.present?
    assert_equal true, @recipient.latitude.present?
    assert_equal true, @recipient.longitude.present?
  end

  test "geocoded by street address and country if no postal code" do
    @recipient.street_address = 'London Road'
    @recipient.save
    assert_equal false, @recipient.postal_code.present?
    assert_equal true, @recipient.street_address.present?
    assert_equal true, @recipient.country.present?
    assert_equal true, @recipient.latitude.present?
    assert_equal true, @recipient.longitude.present?
  end

  test "only geocode for GB" do
    @recipient.street_address = 'London Road'
    @recipient.country = 'KE'
    @recipient.save
    assert_equal false, @recipient.latitude.present?
  end

end
