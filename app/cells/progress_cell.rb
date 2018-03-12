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
      opts = { fund: fund, proposal: proposal, status: eligibility_status }

      sections = {
        request:     ::Progress::Request.new(assessment: model),
        eligibility: ::Progress::Eligibility.new(assessment: model),
        suitability: ::Progress::Suitability.new(opts),
        reveal:      ::Progress::Reveal.new(assessment: model),
        apply:       ::Progress::Apply.new(assessment: model)
      }

      if fund.stub?
        sections.slice(:request, :eligibility, :suitability, :apply).values
      elsif fund.featured? || model&.revealed?
        sections.slice(:eligibility, :suitability, :apply).values
      else
        sections.slice(:eligibility, :suitability, :reveal, :apply).values
      end
    end
end
