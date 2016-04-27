require 'test_helper'

class RecipientFundersTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
  end

  test 'cannot view funder if not active' do
    funder = create(:funder, active_on_beehive: false)
    create(:registered_proposal, recipient: @recipient)
    create_and_auth_user!(organisation: @recipient)
    create(:feedback, user: @user)

    visit funder_path(funder)
    assert_equal recommended_funders_path, current_path
  end

  test 'recommended funders path only shows recommended and eligible funders' do
    setup_funders(3, true)
    @recipient.recommendations.last.update_attribute(:eligibility, 'Ineligible')
    visit recommended_funders_path
    assert page.has_css?('.funder', count: 2)
  end

  test 'eligible funders path only shows eligible funders' do
    setup_funders(3)
    create(:registered_proposal, recipient: @recipient)
    visit eligible_funders_path
    assert_not page.has_css?('.funder', count: 1)
    @recipient.load_recommendation(@funders.first).update_attribute(:eligibility, 'Eligible')
    visit eligible_funders_path
    assert page.has_css?('.funder', count: 1)
  end

  test 'ineligible funders path only shows eligible funders' do
    setup_funders(3)
    create(:registered_proposal, recipient: @recipient)
    visit ineligible_funders_path
    assert_not page.has_css?('.funder', count: 1)
    @recipient.load_recommendation(@funders.first).update_attribute(:eligibility, 'Ineligible')
    visit ineligible_funders_path
    assert page.has_css?('.funder', count: 1)
  end

  test 'all funders path shows all funders' do
    setup_funders(7)
    create(:registered_proposal, recipient: @recipient)
    visit funders_path
    assert page.has_css?('.funder', count: Funder.where(active_on_beehive: true).count)
  end

  test 'recommendation details redacted unless subscribed' do
    setup_funders(7, true)
    visit all_funders_path
    assert page.has_content?('Upgrade', count: 2)
    assert page.has_css?('.redacted', count: 5)

    visit funder_path(@funders[0])
    within('.card') do
      assert page.has_content?('Upgrade')
      assert page.has_css?('.redacted', count: 5)
    end
  end

  test 'funder card displayed with appropriate cta' do
    setup_funders(1, true)
    visit funder_path(@funders[0])
    within('.card-cta') do
      assert_not page.has_content?('More info')
    end
  end

  # test 'cannot visit redacted funder unless subscribed' do
  #   setup_funders(7)
  #   create(:feedback, user: @user)
  #   @recipient.load_recommendation(@funders.last).update_attribute(:score, 0)
  #   visit funder_path(@funders.last)
  #   assert_equal edit_feedback_path(@user.feedbacks.last), current_path
  #   # refactor unless subscribed
  # end

  # test 'redacted funder redirects to upgrade path unless subscribed' do
  #   # refactor unless subscribed
  # end

end
