class Deadline < ActiveRecord::Base

  belongs_to :fund

  validates :fund, :deadline, presence: true

end
