class Priority < Criterion
  validates :category, inclusion: { in: %w(Proposal Recipient) }

  def self.radio_buttons(invert)
    invert ? [['Yes', true], ['No', false]] : [['Yes', false], ['No', true]]
  end

  def suitability(proposal)
    return nil unless proposal
    if category == "Proposal"
      answers.to_a.find{ |f| f.category_id == proposal.id }
    elsif category == "Recipient"
      answers.to_a.find{ |f| f.category_id == proposal.recipient.id }
    end
  end
end
