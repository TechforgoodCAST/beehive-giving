class Assessment < ApplicationRecord
  CHECKS = [
    Check::Eligibility::Amount.new,
    Check::Eligibility::FundingType.new,
    Check::Eligibility::Location.new,
    Check::Eligibility::OrgIncome.new,
    Check::Eligibility::OrgType.new,
    Check::Eligibility::Quiz.new
  ].freeze

  ELIGIBILITY_STATUS_COLUMNS = CHECKS.map do |check|
    "eligibility_#{check.class.name.demodulize.underscore}".to_sym
  end.freeze

  PERMITTED_COLUMNS = (ELIGIBILITY_STATUS_COLUMNS + %i[
    eligibility_quiz_failing
    eligibility_status
    fund_version
  ]).freeze

  belongs_to :fund
  belongs_to :proposal
  belongs_to :recipient

  validates :eligibility_status, inclusion: {
    in: [INELIGIBLE, INCOMPLETE, ELIGIBLE]
  }

  before_validation :set_eligibility_status

  def self.analyse(funds, proposal)
    Check::Each.new(CHECKS).call_each(funds, proposal)
  end

  def self.analyse_and_update!(funds, proposal)
    updates = analyse(funds, proposal)
    Assessment.import!(updates, on_duplicate_key_update: PERMITTED_COLUMNS)
  end

  def attributes
    super.symbolize_keys
  end

  private

    def set_eligibility_status
      self[:eligibility_status] = eligible_status
    end

    def eligible_status
      columns = attributes.slice(*ELIGIBILITY_STATUS_COLUMNS).values
      return INELIGIBLE if columns.any? { |c| c == INELIGIBLE }
      return ELIGIBLE if columns.all? { |c| c == ELIGIBLE }
      INCOMPLETE
    end
end
