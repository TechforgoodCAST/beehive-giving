module Progress
  class Request < Base
    def highlight
      'bg-light-blue' if assessment&.proposal
    end

    def indicator
      assessment&.proposal ? 'bg-blue' : 'bg-grey'
    end

    def label
      'Update fund details'
    end

    def message
      if assessment&.proposal
        if assessment.proposal.recipient.requests.find_by(fund: assessment.fund)
          tag.a('Requested', class: 'btn fs15 slate border-silver disabled')
        else
          link_to('Request', url_helpers.requests_path(fund: assessment.fund), method: :post, class: 'fs15 btn white bg-blue shadow')
        end
      else
        tag.a('Request', class: 'btn fs15 slate border-silver disabled')
      end
    end
  end
end
