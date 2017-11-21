module Progress
  class Request < Base
    def initialize(*args)
      super
      return if @fund.stub?
      @status = @proposal.eligible_status(@fund.slug)
    end

    def label
      'Update fund details'
    end

    def indicator
      "bg-blue #{@position}"
    end

    def message
      link_to('Request', '#eligibility', class: 'fs15 btn white bg-blue shadow')
    end

    def highlight
      'bg-light-blue'
    end
  end
end
