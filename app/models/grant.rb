class Grant < ActiveRecord::Base

  FUNDING_STREAM = ['Main', 'Theme 1', 'Theme 2']
  GRANT_TYPE = ['Unrestricted', 'Core costs', 'Project costs']
  ATTENTION_HOW = ['Headhunting', 'Referral', 'Unsolicited application']

  belongs_to :funder
  belongs_to :recipient

  attr_accessor :skip_validation

  validates :funder, :recipient, presence: true

  validates :funding_stream, :grant_type, :attention_how, :amount_awarded,
  :amount_applied, :installments, :approved_on, :start_on, :end_on,
  :attention_on, :applied_on, presence: true,
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

  validates :amount_awarded,
  numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :installments,
  numericality: {only_integer: true, greater_than_or_equal_to: 1}

end
