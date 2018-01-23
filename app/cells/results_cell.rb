class ResultsCell < Cell::ViewModel
  def eligibility
    opts = { assessment: model }
    ratings = [
      Rating::Eligibility::Amount.new(opts),
      Rating::Eligibility::OrgIncome.new(opts),
      Rating::Eligibility::Location.new(opts),
      Rating::Eligibility::Quiz.new(opts),
      Rating::Eligibility::OrgType.new(opts)
    ]
    render(locals: { ratings: ratings })
  end
end
