module Progress
  class Apply < Base
    def initialize(*args)
      super
      @status = @assessment&.eligible_status
    end

    def label
      'Apply'
    end

    def indicator
      "#{@position} " << if @status == 1
                           'bg-blue'
                         else
                           'bg-grey'
                         end
    end

    def message
      case @status
      when 1
        link_to(
          'Apply ❯',
          url_helpers.apply_proposal_fund_path(@proposal, @fund),
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
