class ProgressCell < Cell::ViewModel
  include ActionView::Helpers::NumberHelper

  property :proposal

  private

    def fund
      model&.fund || OpenStruct.new(stub?: false)
    end

    def total_costs
      number_to_currency(proposal&.total_costs, unit: '£', precision: 0)
    end

    def funding_type
      { 1 => 'Capital', 2 => 'Revenue' }[proposal.funding_type]
    end

    def title
      proposal.title.truncate_words(3) if proposal.complete?
    end

    def proposal_summary
      if model
        [total_costs, funding_type, title].compact.join(' • ')
      else
        link_to 'Conduct check!', '#'
      end
    end

    def steps # TODO: refactor
      opts = { assessment: model }
      if fund.stub?
        [
          ::Progress::Request.new(opts.merge(position: 'bot')),
          ::Progress::Eligibility.new(opts.merge(position: 'top bot')),
          ::Progress::Suitability.new(opts.merge(position: 'top bot')),
          ::Progress::Apply.new(opts.merge(position: 'top'))
        ]
      else
        [
          ::Progress::Eligibility.new(opts.merge(position: 'bot')),
          ::Progress::Suitability.new(opts.merge(position: 'top bot')),
          ::Progress::Apply.new(opts.merge(position: 'top'))
        ]
      end
    end
end
