class Assessment < ApplicationRecord
  CHECKS = [
    Check::Eligibility::Amount,
    Check::Eligibility::Location,
    Check::Eligibility::ProposalCategories,
    Check::Eligibility::Quiz,
    Check::Eligibility::RecipientCategories,
    Check::Suitability::Quiz
  ].freeze

  ELIGIBILITY_COLUMNS = %i[
    eligibility_amount
    eligibility_location
    eligibility_proposal_categories
    eligibility_quiz
    eligibility_recipient_categories
  ].freeze

  SUITABILITY_COLUMNS = %i[
    suitability_quiz
  ].freeze

  PERMITTED_COLUMNS = (ELIGIBILITY_COLUMNS + SUITABILITY_COLUMNS + %i[
    eligibility_quiz_failing
    eligibility_status
    suitability_quiz_failing
    suitability_status
    reasons
  ]).freeze

  belongs_to :fund
  belongs_to :proposal, counter_cache: true
  belongs_to :recipient

  has_many :votes, dependent: :destroy

  validates :eligibility_status, inclusion: {
    in: [INELIGIBLE, INCOMPLETE, ELIGIBLE]
  }

  before_validation :set_eligibility_status, :set_suitability_status

  def self.analyse(funds, proposal)
    Check::Each.new(CHECKS).call_each(funds, proposal)
  end

  def self.analyse_and_update!(funds, proposal)
    updates = analyse(funds, proposal)
    Assessment.import!(updates, on_duplicate_key_update: PERMITTED_COLUMNS)
    Proposal.update_counters(
      proposal.id, assessments_count: proposal.assessments.count
    )
  end

  def attributes
    super.symbolize_keys
  end

  def banner
    @banner ||= Banner.new(self)
  end

  def ratings
    Rating::Each.new(self).ratings
  end

  private

    def set_eligibility_status
      self[:eligibility_status] = eligible_status
    end

    def eligible_status
      columns = attributes.slice(*ELIGIBILITY_COLUMNS).values
      return INELIGIBLE if columns.any? { |c| c == INELIGIBLE }
      return ELIGIBLE if columns.all? { |c| c == ELIGIBLE }

      INCOMPLETE
    end

    def set_suitability_status
      self[:suitability_status] = suitable_status
    end

    def suitable_status
      columns = ELIGIBILITY_COLUMNS + SUITABILITY_COLUMNS
      values = attributes.slice(*columns).values.compact

      return 'avoid' if values.any? { |v| v == INELIGIBLE }
      return 'unclear' if values.any? { |v| v == INCOMPLETE }
      return 'approach' if values.all? { |v| v == ELIGIBLE }

      'unclear'
    end
end
