class Eligibility < ActiveRecord::Base
  belongs_to :category, polymorphic: true
  belongs_to :restriction

  validates :category_id, :category_type, :restriction, presence: true
  validates :eligible,
            inclusion: { in: [true, false],
                         message: 'please select from the list' }
  validates :eligible,
            uniqueness: { scope: [:category, :restriction],
                          message: 'only one per fund' },
            if: :eligible?

  validate :ensure_restriction_category_match

  private

    def ensure_restriction_category_match
      return if category_type == restriction.category
      errors.add(:eligible, "Category must be #{restriction.category}")
    end
end
