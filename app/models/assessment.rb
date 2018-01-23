class Assessment < ApplicationRecord
  CHECKS = [
    Check::Eligibility::Amount.new,
    Check::Eligibility::Location.new,
    Check::Eligibility::OrgIncome.new,
    Check::Eligibility::OrgType.new,
    Check::Eligibility::Quiz.new
  ].freeze

  ELIGIBILITY_COLUMNS = %i[
    eligibility_amount
    eligibility_location
    eligibility_org_income
    eligibility_org_type
    eligibility_quiz
    eligibility_quiz_failing
  ].freeze

  belongs_to :fund
  belongs_to :proposal
  belongs_to :recipient

  def self.analyse(funds, proposal)
    Check::Each.new(CHECKS).call_each(funds, proposal)
  end

  def self.analyse_and_update!(funds, proposal)
    updates = analyse(funds, proposal)
    Assessment.import!(updates, on_duplicate_key_update: ELIGIBILITY_COLUMNS)
  end

  def eligible_status # TODO: refactor
    fields = ELIGIBILITY_COLUMNS.reject { |i| i == :eligibility_quiz_failing }
    res = fields.map { |field| send(field) }.uniq
    return 0 if res.any? { |f| f.try(:zero?) } # Ineligible
    return 1 if res.all? { |status| status == 1 } # Eligible
    -1 # Incomplete
  end
end
