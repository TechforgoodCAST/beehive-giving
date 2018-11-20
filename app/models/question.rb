class Question < ApplicationRecord
  belongs_to :criterion, polymorphic: true
  belongs_to :fund, touch: true
  has_many :answers, through: :criterion
end
