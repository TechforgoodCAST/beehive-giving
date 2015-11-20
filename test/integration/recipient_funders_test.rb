require 'test_helper'

class RecipientFundersTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    @profile = create(:profile, organisation: @recipient, state: 'complete')
  end

  test 'cannot view funder if not active' do
    funder = create(:funder, active_on_beehive: false)
    create_and_auth_user!(organisation: @recipient)

    visit funder_path(funder)
    assert_equal recommended_funders_path, current_path
  end

  test 'recommended funders path only shows recommended and eligible funders' do
    setup_funders(3)
    @recipient.recommendations.last.update_attribute(:eligibility, 'Ineligible')
    visit recommended_funders_path
    assert page.has_css?('.funder', count: 2)
  end

  test 'eligible funders path only shows eligible funders' do
    setup_funders(3)
    visit eligible_funders_path
    assert_not page.has_css?('.funder', count: 1)
    @recipient.load_recommendation(@funders.first).update_attribute(:eligibility, 'Eligible')
    visit eligible_funders_path
    assert page.has_css?('.funder', count: 1)
  end

  test 'ineligible funders path only shows eligible funders' do
    setup_funders(3)
    visit ineligible_funders_path
    assert_not page.has_css?('.funder', count: 1)
    @recipient.load_recommendation(@funders.first).update_attribute(:eligibility, 'Ineligible')
    visit ineligible_funders_path
    assert page.has_css?('.funder', count: 1)
  end

  test 'all funders path shows all funders' do
    setup_funders(7)
    visit funders_path
    assert page.has_css?('.funder', count: Funder.where(active_on_beehive: true).count)
  end

  test 'cannot visit redacted funder unless subscribed' do
    setup_funders(7)
    visit funder_path(@funders.last)
    assert_equal recommended_funders_path, current_path
    # refactor unless subscribed
  end

  test 'cannot check redacted funder unless subscribed' do
    setup_funders(7)
    visit recipient_eligibility_path(@funders.last)
    assert_equal recommended_funders_path, current_path
    # refactor unless subscribed
  end

  test 'redacted funder redirects to upgrade path unless subscribed' do
    # refactor unless subscribed
  end

  test 'recipients without a profile for current year must update profiles' do
    setup_funders(3)

    visit funder_path(@funders.first)
    assert_equal funder_path(@funders.first), current_path

    visit recipient_eligibility_path(@funders.first)
    assert_equal recipient_eligibility_path(@funders.first), current_path

    @recipient.recommendations.first.update_attribute(:eligibility, 'Eligible')
    visit recipient_apply_path(@funders.first)
    assert_equal recipient_apply_path(@funders.first), current_path

    @profile.update_attribute(:year, Date.today.year-1)

    visit funder_path(@funders.first)
    assert_equal new_recipient_profile_path(@recipient), current_path

    visit recipient_eligibility_path(@funders.first)
    assert_equal new_recipient_profile_path(@recipient), current_path

    visit recipient_apply_path(@funders.first)
    assert_equal new_recipient_profile_path(@recipient), current_path
  end

end
