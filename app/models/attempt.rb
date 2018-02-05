class Attempt < ApplicationRecord
  belongs_to :funder
  belongs_to :proposal
  belongs_to :recipient

  validates :funder, :proposal, :recipient, :state, presence: true
end
