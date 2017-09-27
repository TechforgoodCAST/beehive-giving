class Answer < ApplicationRecord
  belongs_to :category, polymorphic: true
  belongs_to :criterion

  validates :category_id, :category_type, :criterion, presence: true
  validates :eligible,
            inclusion: { in: [true, false],
                         message: 'please select from the list' }
  validates :eligible,
            uniqueness: { scope: %i[category criterion],
                          message: 'only one per fund' },
            if: :eligible?

  validate :ensure_criteron_category_match

  private

    def ensure_criteron_category_match
      return if category_type == criteron.category
      errors.add(:eligible, "Category must be #{criteron.category}")
    end
end
