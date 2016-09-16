class EligibilityHelper

  include Capybara::DSL

  def visit_first_fund
    click_link 'Check eligibility', match: :first
    self
  end

  def answer(eligible: true)
    2.times do |i|
      choose "recipient_eligibilities_attributes_#{i}_eligible_#{eligible}"
    end
    self
  end

  def check
    click_button 'Check eligibility (3 left)'
    self
  end

  def update
    click_button 'Update'
    self
  end

end
