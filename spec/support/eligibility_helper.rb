class EligibilityHelper

  include Capybara::DSL

  def visit_first_fund
    click_link 'Check eligibility', match: :first
    self
  end

  def complete_proposal
    fill_in :proposal_title, with: 'Office refurbishment'
    fill_in :proposal_tagline, with: 'Funding to improve the office.'
    check "proposal_implementation_ids_#{Implementation.first.id}"
    fill_in :proposal_outcome1, with: 'Improved employee satisfaction.'
    self
  end

  def submit_proposal
    click_button 'Update and check eligibility'
    self
  end

  def answer(eligible: true, n: 3)
    n.times do |i|
      choose "recipient_eligibilities_attributes_#{i}_eligible_#{eligible}"
    end
    self
  end

  def check_eligibility(remaining: 3)
    click_button "Check eligibility (#{remaining} left)"
    self
  end

  def update
    click_button 'Update'
    self
  end

  def complete_feedback
    select '10 - Very suitable'
    select 'Being able to check your eligibility'
    select '10 - Extremely likely'
    select '10 - Very dissatisfied'
    select '10 - Strongly agree'
    select 'None', from: :feedback_application_frequency
    select 'None', from: :feedback_grant_frequency
    select 'Weekly'
    self
  end

  def submit_feedback
    click_button 'Submit feedback'
    self
  end

end
