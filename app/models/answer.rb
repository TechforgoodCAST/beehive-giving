class Answer < ApplicationRecord
  belongs_to :category, polymorphic: true
  belongs_to :criterion

  validates :category, :criterion, presence: true
  validates :eligible, inclusion: {
    in: [true, false], message: 'please select option'
  }
  validates :eligible, uniqueness: {
    scope: %i[category criterion], message: 'only one per fund'
  }, if: :eligible?

  validate :ensure_criterion_category_match, if: :criterion

  private

    def ensure_criterion_category_match
      return if category_type == criterion.category
      errors.add(:eligible, "Category must be #{criterion.category}")
    end
end
