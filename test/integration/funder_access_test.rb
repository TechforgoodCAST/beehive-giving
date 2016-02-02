require 'test_helper'

class FunderAccessTest < ActionDispatch::IntegrationTest

  setup do
    @funder = create(:funder)
    create(:funder_attribute, funder: @funder)
    3.times { create(:grant, funder: @funder) }
    create_and_auth_user!(role: 'Funder', organisation: @funder)
  end

  test "funder cannot visit new profile path" do
    visit new_recipient_profile_path(@funder)
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder cannot visit profiles index path" do
    visit recipient_profiles_path(@funder)
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder cannot visit recommened eligible ineligible and all funders paths" do
    visit recommended_funders_path
    assert_equal funder_recent_path(@funder), current_path
    visit eligible_funders_path
    assert_equal funder_recent_path(@funder), current_path
    visit ineligible_funders_path
    assert_equal funder_recent_path(@funder), current_path
    visit all_funders_path
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder cannot visit funder show path" do
    visit funder_path(@funder)
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder cannot visit eligibility path" do
    visit recipient_eligibility_path(@funder)
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder cannot visit apply path" do
    visit recipient_apply_path(@funder)
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder cannot visit new proposal path" do
    visit new_recipient_proposal_path(@funder)
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder cannot visit edit proposal path" do
    visit edit_recipient_proposal_path(@funder)
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder cannot visit new feedback path" do
    visit new_feedback_path
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder cannot visit edit feedback path" do
    visit edit_feedback_path
    assert_equal funder_recent_path(@funder), current_path
  end

end
