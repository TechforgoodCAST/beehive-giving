class Restriction < Criterion
  validates :category, inclusion: { in: %w[Proposal Recipient] }

  def eligibility(proposal)
    answer(proposal)
  end
end
