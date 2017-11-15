module Progress
  class Suitability < Base
    def initialize(*args)
      super
      @status = @proposal.suitability[@fund.slug]
                         .all_values_for('score')
                         .count { |s| s > 0.2 }
    end

    def label
      'Suitability'
    end

    def indicator
      "#{@position} " << if @status == 5
                           'bg-green'
                         elsif @status >= 2
                           'bg-yellow'
                         else
                           'bg-red'
                         end
    end

    def message
      if @status == 5
        link_to('Good', '#suitability', link_opts.merge(class: 'green'))
      elsif @status >= 2
        link_to('Review', '#suitability', link_opts.merge(class: 'yellow'))
      else
        link_to('Poor', '#suitability', link_opts.merge(class: 'red'))
      end
    end

    def highlight
      nil
    end
  end
end
