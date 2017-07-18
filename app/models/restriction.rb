class Restriction < ApplicationRecord
  has_and_belongs_to_many :funds # TODO: refactor
  has_many :funders, -> { distinct }, through: :funds
  has_many :eligibilities

  validates :details, presence: true, uniqueness: true
  validates :category, inclusion: { in: %w(Proposal Organisation) }
  validates :has_condition, inclusion: { in: [true, false] }
  validates :condition, presence: true, if: ->(o) { o.has_condition? }

  def self.radio_buttons(invert)
    invert ? [['Yes', true], ['No', false]] : [['Yes', false], ['No', true]]
  end
end
