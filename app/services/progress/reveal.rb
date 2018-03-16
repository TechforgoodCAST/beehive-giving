module Progress
  class Reveal < Base
    def label
      'Reveal fund identity'
    end

    def indicator
      eligible_and_hidden? ? 'bg-blue' : 'bg-grey'
    end

    def message
      if revealed
        disabled_button('Revealed')
      elsif eligibility_status.nil?
        disabled_button('Reveal')
      else
        classes = {
          ELIGIBLE => 'white bg-blue shadow', INELIGIBLE => 'blue border-blue'
        }
        button('Reveal', classes: classes[eligibility_status])
      end
    end

    def highlight
      'bg-light-blue' if eligible_and_hidden?
    end

    private

      def button(text, opts = {})
        link = link_to(
          text,
          url_helpers.reveals_path(assessment: assessment),
          class: "fs15 btn #{opts[:classes]}",
          method: :post
        )
        msg = "#{revealed_count} of #{MAX_FREE_LIMIT} free used"
        "<span class='tooltip tooltip-left' aria-label='#{msg}'>#{link}</span>"
      end

      def disabled_button(text)
        tag.a(text, class: 'btn fs15 slate border-silver disabled')
      end

      def eligible_and_hidden?
        eligibility_status == ELIGIBLE && !revealed
      end

      def revealed_count
        assessment&.recipient ? assessment.recipient.reveals.size : '?'
      end
  end
end
