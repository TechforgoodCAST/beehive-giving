require 'test_helper'

class RecipientAttributeTest < ActiveSupport::TestCase

  setup do
    @recipient = build(:recipient)
    @attribute = build(:recipient_attribute, recipient: @recipient)
  end

  test "recipient attribute belongs to recipient" do
    assert_equal 'Problem', @recipient.attribute.problem
  end

  test "recipient has one recipient attribute" do
    assert_equal 'ACME', @attribute.recipient.name
    @attribute2 = build(:recipient_attribute, recipient: @recipient, problem: "Problem2")
    assert_equal 'Problem2', @recipient.attribute.problem
  end

  test "valid recipient attribute" do
    assert @attribute.valid?
  end

  test "invalid recipient attribute" do
    assert_not build(:recipient_attribute, :recipient_id => nil).valid?
    assert_not build(:recipient_attribute, :problem => nil).valid?
    assert_not build(:recipient_attribute, :solution => nil).valid?
  end

end
