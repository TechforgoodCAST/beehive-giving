class ProgressCell < Cell::ViewModel
  private

    def fund
      model&.fund || OpenStruct.new(stub?: false)
    end

    def proposal
      model&.proposal
    end

    def eligibility_status
      model&.eligibility_status
    end

    def steps # TODO: refactor
      opts = { fund: fund, proposal: proposal, status: eligibility_status }
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
