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

  def answer_recipient_restrictions(fund, eligible: true)
    answer(fund, eligible: eligible, category: 'Organisation', n: 2)
    self
  end

  def answer_proposal_restrictions(fund, eligible: true, n: 3)
    answer(fund, eligible: eligible, n: n)
    self
  end

  def answer_restrictions(fund)
    answer_recipient_restrictions(fund)
    answer_proposal_restrictions(fund)
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

    def answer(fund, category: 'Proposal', eligible: true, n: 3)
      fund.restrictions.where(category: category).limit(n).pluck(:id).each do |i|
        choose "check_restriction_#{i}_eligible_#{eligible}"
      end
    end
end
