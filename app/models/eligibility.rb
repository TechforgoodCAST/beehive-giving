class Eligibility < ActiveRecord::Base

  belongs_to :recipient
  belongs_to :restriction

  validates :eligible, presence: true, unless: Proc.new { |eligibility| eligibility.eligible == false }
  validates :recipient_id, :restriction_id, presence: true
  validates :eligible, inclusion: {:in => [true, false], :message => 'please select from the list'}
  validates_uniqueness_of :eligible, scope: [:recipient_id, :restriction_id], :message => 'only one per funder', if: :eligible?

end
