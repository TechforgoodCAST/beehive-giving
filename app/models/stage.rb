class Stage < ActiveRecord::Base

  STAGES = [
    'Application form',
    'Online application form',
    'Interview',
    'Pitch',
    'Video',
    'Phone call',
    'Meeting',
    'Funding approved',
    'Funding awarded'
  ]

  belongs_to :fund

  validates :fund, :name, :position, presence: true
  validates :name, inclusion: { in: STAGES }, uniqueness: true
  validates :feedback_provided, inclusion: { in: [true, false] }
  validates :position, numericality: { greater_than: 0 }, uniqueness: { scope: :fund }
  validate :position_in_sequence

  private

    def position_in_sequence
      last_stage = Stage.where('fund_id = ? AND id != ?', self.fund_id, self.id).order(:position).last
      if last_stage && self.position
        errors.add(:position, 'Position not in sequence') if self.position > (last_stage.position + 1)
      end
    end

end
