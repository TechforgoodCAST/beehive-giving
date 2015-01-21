require 'test_helper'

class GrantTest < ActiveSupport::TestCase
  setup do
    @funder = create(:funder)
    @grant = build(:grant, funder: @funder)
  end

  test "a grant belongs to a funder" do
    assert_equal 'ACME', @grant.funder.name
  end

  # # Association?
  # test "a valid profile" do
  #   assert @grant.valid?
  # end

  test "only positive numbers are allowed" do
    @grant.amount_awarded = -10
    assert_not @grant.valid?
  end
end
