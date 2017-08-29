class EligibilityHelper
  include Capybara::DSL

  def visit_first_fund
    click_link 'a', class: 'fs22', match: :first
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

  def answer_recipient_restrictions(eligible: true)
    answer(eligible: eligible, category: 'recipient', n: 2)
    self
  end

  def answer_proposal_restrictions(eligible: true, n: 3)
    answer(eligible: eligible, n: n)
    self
  end

  def answer_restrictions
    answer_recipient_restrictions
    answer_proposal_restrictions
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

  def remove_restrictions(fund, category)
    fund.restrictions.where(category: category).destroy_all
    fund.skip_beehive_data = 1
    fund.save!
    self
  end

  private

    def answer(category: 'proposal', eligible: true, n: 3)
      n.times do |i|
        choose "check_#{category}_eligibilities_attributes_" \
               "#{i}_eligible_#{eligible}"
      end
    end
end
