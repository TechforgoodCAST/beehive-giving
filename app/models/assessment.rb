class Assessment < ApplicationRecord
  belongs_to :funder
  belongs_to :recipient
  belongs_to :proposal

  validates :funder, :recipient, :proposal, :state, presence: true
end
