class Enquiry < ApplicationRecord
  belongs_to :fund
  belongs_to :proposal

  validates :approach_funder_count, :fund, :proposal, presence: true
  validates :approach_funder_count, numericality: {
    only_integer: true, greater_than_or_equal_to: 0
  }
  validates :proposal, uniqueness: {
    scope: :fund, message: 'only one enquiry per fund'
  }
end
