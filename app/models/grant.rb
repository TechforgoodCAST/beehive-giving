class Grant < ActiveRecord::Base
  before_validation :default_values

  FUNDING_STREAM = ['All', 'Main', 'Theme 1', 'Theme 2'].freeze
  GRANT_TYPE = ['Unrestricted', 'Core costs', 'Project costs'].freeze
  ATTENTION_HOW = ['Headhunting', 'Referral', 'Unsolicited application'].freeze

  belongs_to :funder
  belongs_to :recipient, counter_cache: true
  has_and_belongs_to_many :countries
  has_and_belongs_to_many :districts

  attr_accessor :skip_validation

  validates :funder, :recipient, presence: true

  validates :funding_stream, :grant_type, :attention_how, :amount_awarded,
            :amount_applied, :installments, :approved_on, :start_on, :end_on,
            :attention_on, :applied_on, :countries, :districts,
            presence: true, unless: :skip_validation

  validates :amount_applied,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            unless: :skip_validation

  validates :funding_stream, inclusion: { in: FUNDING_STREAM },
                             unless: :skip_validation

  validates :grant_type, inclusion: { in: GRANT_TYPE },
                         unless: :skip_validation

  validates :attention_how, inclusion: { in: ATTENTION_HOW },
                            unless: :skip_validation

  validates :amount_awarded, :days_from_attention_to_applied,
            :days_from_applied_to_approved, :days_form_approval_to_start,
            :days_from_start_to_end,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            unless: :skip_validation
  validates :installments,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 },
            unless: :skip_validation

  def self.recent(year = 2015)
    where('approved_on <= ? AND approved_on >= ?',
          "#{year}-12-31", "#{year}-01-01")
  end

  def default_values
    self.days_from_attention_to_applied = (applied_on - attention_on).to_i if attention_on && applied_on
    self.days_from_applied_to_approved = (approved_on - applied_on).to_i if approved_on && applied_on
    self.days_form_approval_to_start = (start_on - approved_on).to_i if start_on && approved_on
    self.days_from_start_to_end = (end_on - start_on).to_i if end_on && start_on
  end
end
