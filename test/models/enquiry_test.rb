require 'test_helper'

class EnquiryTest < ActiveSupport::TestCase

  setup do
    @recipient = build(:recipient)
    @funder = build(:funder)
    @enquiry = build(:enquiry, :recipient => @recipient, :funder => @funder)
    @recommendation = create(:recommendation, :recipient => @recipient, :funder => @funder, :score => 0)
  end

  test "enquiry without new location and poject is valid" do
    assert @enquiry.valid?
  end

  test "enquiry without new location and poject is invalid" do
    @enquiry.amount_seeking = -100
    assert_not @enquiry.valid?
  end

  test "enquiry with new location and project is valid" do
    @enquiry = build(:enquiry_new_location_and_project)
    assert @enquiry.valid?
  end

  test "enquiry with recommendation is valid" do
    @enquiry = build(:enquiry_new_location_and_project)
    assert @enquiry.valid?
  end

  test "enquiry with recommendation is invalid" do
    @enquiry.suggestion_quality = nil
    assert_not @enquiry.valid?
  end

  test "enquiry belongs to recipient" do
    assert_equal 'ACME', @enquiry.recipient.name
  end

  test "enquiry belongs to funder" do
    assert_equal 'ACME', @enquiry.funder.name
  end

end
