class ProposalIndicatorsCell < Cell::ViewModel
  include ActionView::Helpers::NumberHelper

  def eligibility_progress_bar
    @counts = eligibility_counts
    @pcs = count_percentages(@counts)
    bg_color = { -1 => 'bg-blue', 0 => 'bg-red', 1 => 'bg-green' }
    names = { -1 => 'to check', 0 => 'ineligible', 1 => 'eligible' }
    states = [0, 1, -1]
    render view: :progress_bar, locals: {bg_color: bg_color, names: names, states: states}
  end

  def suitability_progress_bar
    @counts = suitability_counts
    @pcs = count_percentages(@counts)
    bg_color = { 0 => 'bg-red', 1 => 'bg-yellow', 2 => 'bg-green', -1 => 'bg-blue' }
    names = { 0 => 'unsuitable', 1 => 'fair suitability', 2 => 'suitable', -1 => 'to check' }
    states = [-1, 0, 1, 2]
    render view: :progress_bar, locals: {bg_color: bg_color, names: names, states: states}
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

    def count_percentages(counts)
      total = counts.values.inject(0, :+).to_f
      counts.map{|k, v| [k, v / total]}.to_h
    end

    def eligibility_counts
      {
        -1 => model.to_check_funds.count,
        0 => model.ineligible_funds.count,
        1 => model.eligible_funds.count
      }
    end

    def suitability_counts
      {
        -1 => model.suitability.count{ |k, s| s.fetch('total') == nil },
        0 => model.suitability.count{ |k, s| s.fetch('total') < 0.2 },
        1 => model.suitability.count{ |k, s| s.fetch('total').between?(0.2, 0.5) },
        2 => model.suitability.count{ |k, s| s.fetch('total') > 0.5 },
      }
    end
end
