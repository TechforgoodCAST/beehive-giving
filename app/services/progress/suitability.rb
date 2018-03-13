module Progress
  class Suitability < Base
    def initialize(*args)
      super
      @status = suitability
    end

    def label
      'Suitability'
    end

    def indicator
      if @status.nil?
        'bg-grey'
      elsif @status == 5
        'bg-green'
      elsif @status >= 2
        'bg-yellow'
      else
        'bg-red'
      end
    end

    def message
      return if @status.nil?
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

    private

      def suitability
        return unless @proposal&.suitability.try(:[], @fund.slug)
        @proposal.suitability[@fund.slug]
                 .all_values_for('score')
                 .count { |s| s > 0.2 }
      end
  end
end
