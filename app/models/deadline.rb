class Deadline < ActiveRecord::Base
  belongs_to :fund

  validates :fund, :deadline, presence: true
  validate :future_deadline, on: :create

  private

    def future_deadline
      errors.add(:deadline) if deadline < Date.today
    end
end
