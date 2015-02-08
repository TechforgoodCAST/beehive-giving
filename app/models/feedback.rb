class Feedback < ActiveRecord::Base
  belongs_to :user

  validates :nps, :taken_away, :informs_decision, presence: true
  validate :nps, :taken_away, :informs_decision, inclusion: {in: 1..10}
end
