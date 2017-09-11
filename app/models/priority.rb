class Priority < Question
  has_and_belongs_to_many :funds # TODO: refactor
  has_many :funders, -> { distinct }, through: :funds
  has_many :answers

  validates :details, presence: true, uniqueness: true
  validates :category, inclusion: { in: %w(Proposal Organisation) }

  def self.radio_buttons(invert)
    invert ? [['Yes', true], ['No', false]] : [['Yes', false], ['No', true]]
  end

  def suitability(proposal)
    return nil unless proposal
    if category == "Proposal"
      answers.to_a.find{ |f| f.category_id == proposal.id }
    elsif category == "Organisation"
      answers.to_a.find{ |f| f.category_id == proposal.recipient.id }
    end
  end
end
