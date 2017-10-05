class Question < ApplicationRecord
    scope :grouped, ->(type, group) { where(criterion_type: type, group: group) }
    belongs_to :criterion, polymorphic: true, dependent: :destroy
    belongs_to :fund
    has_many :answers, through: :criterion
end