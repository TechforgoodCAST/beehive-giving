class ProposalIndicatorsCell < Cell::ViewModel
  include ActionView::Helpers::NumberHelper

  def eligibility_progress_bar
    @counts = eligibility_counts
    @pcs = eligibility_percentages(@counts)
    render
  end

  def percent_complete
    case model.state
    when 'initial'
      complete = 0.25
    when 'transferred'
      complete = 0.5
    when 'registered'
      complete = 0.75
    when 'complete'
      complete = 1
    end
    render locals: {complete: complete}
  end

  def funds_checked
    counts = eligibility_counts
    render locals: {complete: counts[0] + counts[1]}
  end

  private

    def bg_color(status)
      { -1 => 'bg-blue', 0 => 'bg-red', 1 => 'bg-green' }[status]
    end

    def name(status)
      { -1 => 'to check', 0 => 'ineligible', 1 => 'eligible' }[status]
    end

    def eligibility_counts
      {
        -1 => model.to_check_funds.count,
        0 => model.ineligible_funds.count,
        1 => model.eligible_funds.count
      }
    end

    def eligibility_percentages(counts)
      total = counts.values.inject(0, :+).to_f
      counts.map{|k, v| [k, v / total]}.to_h
    end
end
