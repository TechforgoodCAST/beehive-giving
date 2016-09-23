# TODO: deprecated
require 'test_helper'

class FunderAccessTest < ActionDispatch::IntegrationTest

  setup do
    @funder = create(:funder)
    # TODO: refactor
    seed_test_db
    create(:funder_attribute, funder: @funder, countries: @countries, districts: @districts)
    3.times { create(:grant, funder: @funder, countries: @countries, districts: @districts) }
    @funder.update_current_attribute
    create_and_auth_user!(role: 'Funder', organisation: @funder)
  end

  test "funder can only view their own proposals" do
    skip
    funder2 = create(:funder)
    visit funder_recent_path(funder2)
    assert_equal funder_recent_path(@funder), current_path
  end

  test "funder can only view their own districts" do
    funder2 = create(:funder)
    create(:funder_attribute, funder: funder2, countries: @countries, districts: @districts)
    @funder.current_attribute.update_attribute(:grant_count, 10)
    district = @funder.grants.last.districts.last
    district.update_attribute(:slug, 'birmingham')
    visit funder_district_path(funder2, district.slug)
    assert_equal funder_district_path(@funder, district.slug), current_path
  end

  test "funder cannot visit recommened eligible ineligible and all funders paths" do
    skip
    visit recommended_funds_path
    assert_equal funder_overview_path(@funder), current_path
    visit eligible_funders_path
    assert_equal funder_overview_path(@funder), current_path
    visit ineligible_funders_path
    assert_equal funder_overview_path(@funder), current_path
    visit all_funders_path
    assert_equal funder_overview_path(@funder), current_path
  end

  test "funder cannot visit funder show path" do
    visit funder_path(@funder)
    assert_equal funder_overview_path(@funder), current_path
  end

  test "funder cannot visit eligibility path" do
    skip
    visit recipient_eligibility_path(@funder)
    assert_equal funder_overview_path(@funder), current_path
  end

  test "funder cannot visit apply path" do
    skip
    visit recipient_apply_path(@funder)
    assert_equal funder_overview_path(@funder), current_path
  end

  test "funder cannot visit new proposal path" do
    visit new_recipient_proposal_path(@funder)
    assert_equal funder_overview_path(@funder), current_path
  end

  test "funder cannot visit edit proposal path" do
    visit edit_recipient_proposal_path(@funder)
    assert_equal funder_overview_path(@funder), current_path
  end

  test "funder cannot visit proposal index path" do
    visit recipient_proposals_path(@funder)
    assert_equal funder_overview_path(@funder), current_path
  end

  test "funder cannot visit new feedback path" do
    visit new_feedback_path
    assert_equal funder_overview_path(@funder), current_path
  end

  test "funder cannot visit edit feedback path" do
    create(:feedback, user: User.new)
    visit edit_feedback_path(Feedback.first)
    assert_equal funder_overview_path(@funder), current_path
  end

end
