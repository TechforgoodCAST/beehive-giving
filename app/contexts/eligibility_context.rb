class EligibilityContext < ApplicationContext
  def self.policy_class
    EligibilityPolicy
  end

  def checked_fund?
    @proposal.eligibility[@fund.slug]&.all_values_for('quiz').present?
  end
end
