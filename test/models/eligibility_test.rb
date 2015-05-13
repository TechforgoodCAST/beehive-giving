require 'test_helper'

class EligibilityTest < ActiveSupport::TestCase

  setup do
    @eligibility = build(:eligibility)
  end

  test "valid eligibility" do
    assert @eligibility.valid?
  end

  test "eligible as false is valid" do
    assert build(:eligibility, :eligible => false).valid?
  end

  test "recipient missing is invalid" do
    assert_not build(:eligibility, :recipient_id => nil).valid?
  end

  test "restriction missing is invalid" do
    assert_not build(:eligibility, :restriction_id => nil).valid?
  end

end
