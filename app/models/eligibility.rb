class Eligibility < ActiveRecord::Base
  belongs_to :recipient
  belongs_to :restriction

  validates :recipient, :restriction, presence: true

  validates :eligible,
            inclusion: { in: [true, false], message: 'please select from the list' }
  validates :eligible,
            uniqueness: { scope: [:recipient, :restriction], message: 'only one per funder' },
            if: :eligible?
end
