require 'test_helper'

class EnquiryTest < ActiveSupport::TestCase

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder)
    @enquiry = create(:enquiry, :recipient => @recipient, :funder => @funder)
  end

  test "enquiry is valid" do
    assert @enquiry.valid?
  end

  test "enquiry belongs to recipient" do
    assert_equal 'ACME', @enquiry.recipient.name
  end

  test "enquiry belongs to funder" do
    assert_equal 'ACME', @enquiry.funder.name
  end

  test "only one enquiry per recipient funder and funding stream relationship" do
    assert_not build(:enquiry, :recipient => @recipient, :funder => @funder).valid?
  end

end
