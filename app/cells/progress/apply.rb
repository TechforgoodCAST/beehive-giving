module Progress
  class Apply < Base
    def label
      'Apply'
    end

    def indicator
      @position.to_s << if eligibility_status == ELIGIBLE
                          ' bg-blue'
                        else
                          ' bg-grey'
                        end
    end

    def message
      if eligible_and_revealed?
        link_to(
          'Apply ❯',
          url_helpers.apply_path(fund_hashid, proposal_id),
          class: 'fs15 btn white bg-blue shadow'
        )
      else
        tag.a('Apply ❯', class: 'btn fs15 slate border-silver disabled')
      end
    end

    def highlight
      'bg-light-blue' if eligible_and_revealed?
    end

    private

      def fund_hashid
        HASHID.encode(@assessment.fund_id)
      end

      def proposal_id
        @assessment.proposal_id
      end

      def eligible_and_revealed?
        eligibility_status == ELIGIBLE && revealed
      end
  end
end
