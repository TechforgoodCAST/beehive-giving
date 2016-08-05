require 'test_helper'

class RecipientFeedbackTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    setup_funders(4)
    create(:proposal, recipient: @recipient, countries: @countries, districts: @districts, age_groups: @age_groups, beneficiaries: @beneficiaries)
  end

  test 'feedback prompt before third funder check' do
    # First funder unlock
    @recipient.unlock_funder!(@funders[0])

    # Second funder unlock
    @recipient.unlock_funder!(@funders[1])

    # Checking third funders pages redirects if no feedback
    visit recipient_eligibility_path(@funders[2])
    assert_equal new_feedback_path, current_path

    # Visiting fourth funders pages redirects if no feedback
    visit recipient_eligibility_path(@funders[3])
    assert_equal new_feedback_path, current_path

    # completing feedback form redirects to funder
    visit recipient_eligibility_path(@funders[2])
    within('#new_feedback') do
      select('10 - Very suitable', from: 'feedback_suitable')
      select(Feedback::MOST_USEFUL.sample, from: 'feedback_most_useful')
      select('10 - Extremely likely', from: 'feedback_nps')
      select('10 - Very dissatisfied', from: 'feedback_taken_away')
      select('10 - Strongly agree', from: 'feedback_informs_decision')
      select(Feedback::APP_AND_GRANT_FREQUENCY.sample, from: 'feedback_application_frequency')
      select(Feedback::APP_AND_GRANT_FREQUENCY.sample, from: 'feedback_grant_frequency')
      select(Feedback::MARKETING_FREQUENCY.sample, from: 'feedback_marketing_frequency')
    end
    click_button('Submit feedback')
    assert_equal recipient_eligibility_path(@funders[2]), current_path

    # Feedback only required for second unlock
    visit recipient_eligibility_path(@funders[3])
    assert_equal recipient_eligibility_path(@funders[3]), current_path
  end

end
