class RecipientAttribute < ActiveRecord::Base

  belongs_to :recipient

  validates :recipient, :problem, :solution, presence: true
  validates :problem, :solution, length: { maximum: 1000 }
  validates_uniqueness_of :recipient_id, :message => 'only one per organisation'

end
