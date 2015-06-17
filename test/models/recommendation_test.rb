require 'test_helper'

class RecommendationTest < ActiveSupport::TestCase

  setup do
    @recipient = create(:recipient)
    @funder = create(:funder)
    @recommendation = create(:recommendation, :recipient => @recipient, :funder => @funder)
  end

  test "valid recommendation" do
    assert @recommendation.valid?
  end

  test "invalid recommendation" do
    @recommendation.funder = nil
    assert_not @recommendation.valid?
  end

  test "recommendation belongs to recipient" do
    assert_equal @recommendation.recipient, @recipient
  end

  test "recommendation belongs to funder" do
    assert_equal @recommendation.funder, @funder
  end

  test "only one recommendation per recipient funder relationship" do
    assert_not build(:recommendation, :recipient => @recipient, :funder => @funder).valid?
  end

end
