module Progress
  class Apply < Base
    def highlight
      'bg-light-blue' if eligible_and_revealed?
    end

    def indicator
      eligibility_status == ELIGIBLE ? 'bg-blue' : 'bg-grey'
    end

    def label
      'Apply'
    end

    def message
      if eligible_and_revealed?
        link_to(
          'Apply ❯',
          url_helpers.apply_path(fund_hashid, proposal_id),
          class: 'fs15 btn-sm white bg-blue shadow'
        )
      else
        tag.a('Apply ❯', class: 'btn-sm fs15 slate border-silver disabled')
      end
    end

    private

      def eligible_and_revealed?
        eligibility_status == ELIGIBLE && revealed
      end

      def fund_hashid
        HASHID.encode(assessment.fund_id)
      end

      def proposal_id
        assessment.proposal_id
      end
  end
end
