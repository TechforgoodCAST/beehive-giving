module Progress
  class Eligibility < Base
    def highlight
      return if eligibility_status.nil?
      'bg-light-blue' unless eligibility_status == ELIGIBLE
    end

    def indicator
      {
        UNASSESSED => 'bg-grey',
        INELIGIBLE => 'bg-red',
        INCOMPLETE => 'bg-blue',
        ELIGIBLE   => 'bg-green'
      }[eligibility_status]
    end

    def label
      'Eligibility'
    end

    def message
      case eligibility_status
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
  end
end
