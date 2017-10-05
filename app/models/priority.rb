class Priority < Criterion
  validates :category, inclusion: { in: %w(Proposal Recipient) }

  def suitability(proposal)
    answer(proposal)
  end
end
