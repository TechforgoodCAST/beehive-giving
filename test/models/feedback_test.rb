require 'test_helper'

class FeedbackTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @feedback = build(:feedback, user: @user)
  end

  test "feedback belongs to user" do
    assert_equal 'John', @user.first_name
  end

  test "valid feedback" do
    assert @feedback.valid?
  end

  test "invalid feedback" do
    @feedback.nps = -10
    @feedback.taken_away = nil
    assert_not @feedback.valid?
  end
end
