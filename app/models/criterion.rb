# TODO: spec
class Criterion < ApplicationRecord
  has_many :questions
  has_many :funds, through: :questions
  has_many :funders, -> { distinct }, through: :funds
  has_many :answers

  validates :details, presence: true, uniqueness: true

  # TODO: remove?
  def answer(proposal)
    return nil unless proposal
    category_id = (category == 'Recipient' ? proposal.recipient.id : proposal.id )
    answers.where(category_id: category_id, category_type: category).first
  end

  # TODO: remove
  def form_input_id
    "question_#{id}"
  end

  def radio_button_values
    invert ? [['Yes', true], ['No', false]] : [['Yes', false], ['No', true]]
  end
end
