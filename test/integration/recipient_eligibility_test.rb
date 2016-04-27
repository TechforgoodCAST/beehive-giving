require 'test_helper'

class RecipientEligibilityTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    setup_funders(3, true)
  end

  test 'recipient no eligibility data has to complete all questions' do
    Capybara.match = :first
    visit funder_path(@funders[0])
    click_link('Check eligibility')

    assert_equal recipient_eligibility_path(@funders[0]), current_path
    assert page.has_content?('Yes', count: 3)
  end

  test 'recipient with partial eligibility data able to fill gaps' do
    Array.new(3) { |i| create(:eligibility, recipient: @recipient, restriction: @restrictions[i]) }
    Eligibility.last.destroy

    visit recipient_eligibility_path(@funders[0])
    assert page.has_content?('Yes', count: 1)
  end

  test 'eligible recipient can apply for funding' do
    @recipient.load_recommendation(@funders[0]).update_attribute(:eligibility, 'Eligible')

    visit recipient_apply_path(@funders[0])
    assert_equal recipient_apply_path(@funders[0]), current_path
  end

  test 'ineligible recipient cannot visit apply for funding page' do
    @recipient.load_recommendation(@funders[0]).update_attribute(:eligibility, 'Ineligible')

    visit recipient_apply_path(@funders[0])
    assert_equal recipient_eligibility_path(@funders[0]), current_path
  end

  test 'cannot check eligibility if max free limit reached unless subscribed' do
    create(:feedback, user: @user)
    @funders.each { |f| @recipient.unlock_funder!(f) }
    create(:funder)

    visit recipient_eligibility_path(@recipient.unlocked_funders.first)
    assert_equal recipient_eligibility_path(@recipient.unlocked_funders.first), current_path

    visit recipient_eligibility_path(@recipient.locked_funders.first)
    assert_equal edit_feedback_path(@user.feedbacks.last), current_path

    # refactor test unless subscribed
  end

  test 'funder card displayed with appropriate cta' do
    visit recipient_eligibility_path(@funders[0])
    assert_not page.has_css?('.card-cta')
  end

end
