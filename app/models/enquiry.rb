class Enquiry < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :fund

  validates :proposal, :fund, :approach_funder_count, presence: true
  validates :approach_funder_count,
            numericality: { only_integer: true,
                            greater_than_or_equal_to: 0 }
  validates :proposal, uniqueness: { scope: :fund,
                                     message: 'only one enquiry per fund' }
end
