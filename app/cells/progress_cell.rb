class ProgressCell < Cell::ViewModel
  private

    def eligibility_status
      model&.eligibility_status
    end

    def fund
      model&.fund || OpenStruct.new(stub?: false)
    end

    def position(i)
      if i.zero?
        ' bot'
      elsif i == (steps.size - 1)
        ' top'
      else
        ' bot top'
      end
    end

    def proposal
      model&.proposal
    end

    def steps # TODO: refactor
      old_opts = { fund: fund, proposal: proposal, status: eligibility_status }
      opts = { assessment: model, featured: fund.featured? }

      sections = {
        request:     Progress::Request.new(opts),
        eligibility: Progress::Eligibility.new(opts),
        suitability: Progress::Suitability.new(old_opts),
        reveal:      Progress::Reveal.new(opts),
        apply:       Progress::Apply.new(opts)
      }

      if fund.stub?
        sections.slice(:request, :eligibility, :suitability, :apply).values
      elsif options[:subscribed] || fund.featured? || model&.revealed?
        sections.slice(:eligibility, :suitability, :apply).values
      else
        sections.slice(:eligibility, :suitability, :reveal, :apply).values
      end
    end
end
