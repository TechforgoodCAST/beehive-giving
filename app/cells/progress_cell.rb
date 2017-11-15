class ProgressCell < Cell::ViewModel
  include ActionView::Helpers::NumberHelper

  private

    def total_costs
      number_to_currency(model.total_costs, unit: '£', precision: 0)
    end

    def funding_type
      { 1 => 'Capital', 2 => 'Revenue' }[model.funding_type]
    end

    def title
      model.title.truncate_words(3) if model.complete?
    end

    def proposal_summary
      [total_costs, funding_type, title].compact.join(' • ')
    end

    def steps
      opts = { proposal: model, fund: options[:fund] }
      [
        ::Progress::Eligibility.new(opts.merge(position: 'bot')),
        ::Progress::Suitability.new(opts.merge(position: 'top bot')),
        ::Progress::Apply.new(opts.merge(position: 'top'))
      ]
    end
end
