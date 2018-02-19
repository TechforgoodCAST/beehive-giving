module Progress
  class Apply < Base
    def label
      'Apply'
    end

    def indicator
      "#{@position} " << if @status == ELIGIBLE
                           'bg-blue'
                         else
                           'bg-grey'
                         end
    end

    def message
      case @status
      when ELIGIBLE
        link_to(
          'Apply ❯',
          url_helpers.apply_path(@fund, @proposal),
          class: 'fs15 btn white bg-blue shadow'
        )
      else
        tag.a('Apply ❯', class: 'btn fs15 slate border-silver disabled')
      end
    end

    def highlight
      'bg-light-blue' if @status == 1
    end
  end
end
