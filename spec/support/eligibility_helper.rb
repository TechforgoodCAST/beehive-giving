class EligibilityHelper
  include Capybara::DSL

  def visit_first_fund
    click_link 'Hidden fund', match: :first
    self
  end

  def answer_recipient_restrictions(fund, eligible: true)
    answer_restriction(fund, eligible: eligible, category: 'Recipient', n: 2)
    self
  end

  def answer_proposal_restrictions(fund, eligible: true, n: 3)
    answer_restriction(fund, eligible: eligible, n: n)
    self
  end

  def answer_restrictions(fund)
    answer_recipient_restrictions(fund)
    answer_proposal_restrictions(fund)
    self
  end

  def check_eligibility
    click_button 'Check eligibility', match: :first
    self
  end

  def answer_recipient_priorities(fund, eligible: true)
    answer_priority(fund, eligible: eligible, category: 'Recipient', n: 2)
    self
  end

  def answer_proposal_priorities(fund, eligible: true, n: 3)
    answer_priority(fund, eligible: eligible, n: n)
    self
  end

  def answer_priorities(fund)
    answer_recipient_priorities(fund)
    answer_proposal_priorities(fund)
    self
  end

  def check_suitability
    click_button 'Check suitability', match: :first
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
    fund.save!
    self
  end

  private

    def answer_restriction(fund, category: 'Proposal', eligible: true, n: 3)
      fund.restrictions.where(category: category).limit(n).pluck(:id).each do |i|
        choose "check_question_#{i}_#{eligible}"
      end
    end

    def answer_priority(fund, category: 'Proposal', eligible: true, n: 3)
      fund.priorities.where(category: category).limit(n).pluck(:id).each do |i|
        choose "check_question_#{i}_#{eligible}"
      end
    end
end
