class Answer < ApplicationRecord
  belongs_to :category, polymorphic: true
  belongs_to :question

  validates :category_id, :category_type, :question, presence: true
  validates :eligible,
            inclusion: { in: [true, false],
                         message: 'please select from the list' }
  validates :eligible,
            uniqueness: { scope: [:category, :question],
                          message: 'only one per fund' },
            if: :eligible?

  validate :ensure_question_category_match

  private

    def ensure_question_category_match
      return if category_type == question.category
      errors.add(:eligible, "Category must be #{question.category}")
    end
end
