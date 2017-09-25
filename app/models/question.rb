class Question < ApplicationRecord
  has_and_belongs_to_many :funds # TODO: refactor
  has_many :funders, -> { distinct }, through: :funds
  has_many :answers

  validates :details, presence: true, uniqueness: true

  def self.radio_buttons(invert)
    invert ? [['Yes', true], ['No', false]] : [['Yes', false], ['No', true]]
  end
end
