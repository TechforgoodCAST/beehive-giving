class Criterion < ApplicationRecord
  has_many :questions
  has_many :funds, through: :questions
  has_many :funders, -> { distinct }, through: :funds
  has_many :answers

  validates :details, presence: true, uniqueness: true

  def self.radio_buttons(invert)
    invert ? [['Yes', true], ['No', false]] : [['Yes', false], ['No', true]]
  end

  def answer(proposal)
    return nil unless proposal
    category_id = (category == 'Recipient' ? proposal.recipient.id : proposal.id )
    answers.where(category_id: category_id, category_type: category).first
  end
end
