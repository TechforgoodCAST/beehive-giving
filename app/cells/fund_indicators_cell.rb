class FundIndicatorsCell < Cell::ViewModel
  property :slug

  def show
    @proposal = options[:proposal]
    @eligible_status = @proposal.eligible_status(slug)
    render
  end

  def dot
    @proposal = options[:proposal]
    @eligible_status = eligibility_criteria_status
    render locals: {large: options[:large]}
  end

  def tag
    @proposal = options[:proposal]
    @eligible_status = eligibility_criteria_status
    render locals: {large: options[:large]}
  end

  private

    def bg_color(status)
      { -1 => 'bg-blue', 0 => 'bg-red', 1 => 'bg-green' }[status]
    end

    def eligibility_text(status)
      { -1 => 'Check eligibility', 0 => 'Ineligible', 1 => 'Eligible' }[status]
    end

    def eligibility_criteria_status
      return -1 if options[:criteria] == 'quiz' && !options[:proposal].checked_fund?(model)
      (options[:proposal].ineligible_reasons(model.slug).include? options[:criteria]) ? 0 : 1
    end
end
