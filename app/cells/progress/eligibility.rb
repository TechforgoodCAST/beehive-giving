module Progress
  class Eligibility < Base
    def initialize(*args)
      super
      return if @fund.stub?
      @status = @proposal.eligible_status(@fund.slug)
    end

    def label
      'Eligibility'
    end

    def indicator
      return " #{@position}" if @status.nil?
      {
        -1 => 'bg-blue', 0 => 'bg-red', 1 => 'bg-green'
      }[@status] << " #{@position}"
    end

    def message
      case @status
      when nil
        "Missing"
      when -1
        link_to(
          'Complete this check',
          '#eligibility-quiz',
          link_opts.merge(class: 'fs15 btn white bg-blue shadow')
        )
      when 0
        link_to('Ineligible', '#eligibility', link_opts.merge(class: 'red'))
      when 1
        link_to('Eligible', '#eligibility', link_opts.merge(class: 'green'))
      end
    end

    def highlight
      return '' if @status.nil?
      'bg-light-blue' unless @status == 1
    end
  end
end
