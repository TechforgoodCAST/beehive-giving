module Progress
  class Reveal < Base
    def label
      'Reveal fund identity'
    end

    def indicator
      @position.to_s << if eligible_and_hidden?
                          ' bg-blue'
                        else
                          ' bg-grey'
                        end
    end

    def message
      if revealed
        disabled_button('Revealed')
      elsif eligibility_status == ELIGIBLE || INELIGIBLE
        classes = {
          ELIGIBLE => 'white bg-blue shadow', INELIGIBLE => 'blue border-blue'
        }
        button('Reveal', classes: classes[eligibility_status])
      else
        disabled_button('Reveal')
      end
    end

    def highlight
      'bg-light-blue' if eligible_and_hidden?
    end

    private

      def button(text, opts = {})
        link_to(
          text,
          url_helpers.reveals_path(assessment: @assessment),
          class: "fs15 btn #{opts[:classes]}",
          method: :post
        )
      end

      def disabled_button(text)
        tag.a(text, class: 'btn fs15 slate border-silver disabled')
      end

      def eligible_and_hidden?
        eligibility_status == ELIGIBLE && !revealed
      end
  end
end
