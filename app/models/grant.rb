class Grant < ActiveRecord::Base
  before_save :default_values

  def default_values
    self.days_from_attention_to_applied = (self.applied_on - self.attention_on).to_i if self.attention_on && self.applied_on
    self.days_from_applied_to_approved = (self.approved_on - self.applied_on).to_i if self.approved_on && self.applied_on
    self.days_form_approval_to_start = (self.start_on - self.approved_on).to_i if self.start_on && self.approved_on
    self.days_from_start_to_end = (self.end_on - self.start_on).to_i if self.end_on && self.start_on
  end

  FUNDING_STREAM = ['Main', 'Theme 1', 'Theme 2']
  GRANT_TYPE = ['Unrestricted', 'Core costs', 'Project costs']
  ATTENTION_HOW = ['Headhunting', 'Referral', 'Unsolicited application']

  belongs_to :funder
  belongs_to :recipient

  attr_accessor :skip_validation

  validates :funder, :recipient, presence: true

  validates :funding_stream, :grant_type, :attention_how, :amount_awarded,
  :amount_applied, :installments, :approved_on, :start_on, :end_on,
  :attention_on, :applied_on, :country, presence: true,
  unless: :skip_validation

  validates :amount_applied,
  numericality: {only_integer: true, greater_than_or_equal_to: 0},
  unless: :skip_validation

  validates :funding_stream, inclusion: {in: FUNDING_STREAM},
  unless: :skip_validation

  validates :grant_type, inclusion: {in: GRANT_TYPE},
  unless: :skip_validation

  validate :attention_how, inclusion: {in: ATTENTION_HOW},
  unless: :skip_validation

  validates :amount_awarded, :days_from_attention_to_applied, :days_from_applied_to_approved,
  :days_form_approval_to_start, :days_from_start_to_end,
  numericality: {only_integer: true, greater_than_or_equal_to: 0}, unless: :skip_validation
  validates :installments,
  numericality: {only_integer: true, greater_than_or_equal_to: 1}

end
