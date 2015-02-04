class Feedback < ActiveRecord::Base
  belongs_to :user

  validates :nps, :taken_away, presence: true
  validate :nps, :taken_away, inclusion: {in: 1..10}
end
