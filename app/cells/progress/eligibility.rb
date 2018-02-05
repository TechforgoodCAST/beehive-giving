module Progress
  class Eligibility < Base
    def label
      'Eligibility'
    end

    def indicator
      {
        UNASSESSED => 'bg-grey',
        INELIGIBLE => 'bg-red',
        INCOMPLETE => 'bg-blue',
        ELIGIBLE   => 'bg-green'
      }[@status] + " #{@position}"
    end

    def message
      case @status
      when INELIGIBLE
        link_to('Ineligible', '#eligibility', link_opts.merge(class: 'red'))
      when INCOMPLETE
        link_to(
          'Complete this check',
          '#eligibility-quiz',
          link_opts.merge(class: 'fs15 btn white bg-blue shadow')
        )
      when ELIGIBLE
        link_to('Eligible', '#eligibility', link_opts.merge(class: 'green'))
      end
    end

    def highlight
      return if @status.nil?
      'bg-light-blue' unless @status == 1
    end
  end
end
