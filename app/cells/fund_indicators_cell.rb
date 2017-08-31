class FundIndicatorsCell < Cell::ViewModel
  property :slug

  def show
    @proposal = options[:proposal]
    @eligible_status = @proposal.eligible_status(slug)
    render
  end

  private

    def bg_color(status)
      { -1 => 'bg-blue', 0 => 'bg-red', 1 => 'bg-green' }[status]
    end

    def eligibility_text(status)
      { -1 => 'Check eligibility', 0 => 'Ineligible', 1 => 'Eligible' }[status]
    end
end
