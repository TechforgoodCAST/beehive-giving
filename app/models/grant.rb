class Grant < ActiveRecord::Base

  FUNDING_STREAM = ['Main', 'Theme 1', 'Theme 2']
  GRANT_TYPE = ['Unrestricted', 'Core costs', 'Project costs']
  ATTENTION_HOW = ['Headhunting', 'Referral', 'Unsolicited application']

  belongs_to :funder
  belongs_to :organisation

  validates :organisation, presence: true
  validates :funding_stream, :grant_type, :attention_how, :amount_awarded,
  :amount_applied, :installments, :approved_on, :start_on, :end_on,
  :attention_on, :applied_on, presence: true
  validates :amount_awarded, :amount_applied,
  numericality: {only_integer: true, greater_than_or_equal_to: 0}
  validates :installments,
  numericality: {only_integer: true, greater_than_or_equal_to: 1}
  validates :funding_stream, inclusion: {in: FUNDING_STREAM}
  validates :grant_type, inclusion: {in: GRANT_TYPE}
  validate :attention_how, inclusion: {in: ATTENTION_HOW}

end
