class Vote < ApplicationRecord
  belongs_to :assessment

  ROLES = [
    'I created the report',
    'I work for the opportunity provider',
    'Another role'
  ].freeze

  validates :relationship_to_assessment, presence: { in: ROLES }

  validates :relationship_details, presence: true, if: ->(o) {
    o.relationship_to_assessment == 'Another role'
  }

  validates :agree_with_rating, inclusion: { in: [true, false] }

  validates :reason, presence: true, unless: :agree_with_rating

  after_save :update_counter_caches

  private

    def update_counter_caches
      if agree_with_rating
        Assessment.increment_counter(:agree_count, assessment)
      else
        Assessment.increment_counter(:disagree_count, assessment)
      end
    end
end
