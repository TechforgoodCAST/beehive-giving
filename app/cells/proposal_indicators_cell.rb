class ProposalIndicatorsCell < Cell::ViewModel
  include ActionView::Helpers::NumberHelper 

  def eligibility_progress_bar
    @counts = eligibility_counts
    @pcs = eligibility_percentages(@counts)
    render
  end

  def percent_complete
    pcs = eligibility_percentages(eligibility_counts)
    render locals: {complete: pcs[0] + pcs[1]}
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
