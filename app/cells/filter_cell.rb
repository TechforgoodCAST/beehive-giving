include ERB::Util

class FilterCell < Cell::ViewModel
  def show
    @proposal = options[:proposal]
    @url = options[:url]
    render
  end

  private

    def selected?(id, value)
      model[id.to_sym] == value
    end

    def select(id, options)
      tag.select id: id, name: id, class: 'input' do
        options.map do |opt|
          opt = [opt, opt.gsub('-', ' ').capitalize] unless opt.is_a?(Array)
          tag.option(opt[1], value: url_encode(opt[0]), selected: selected?(id, opt[0]))
        end.reduce(:+)
      end
    end

    def proposal_duration
      ['proposal', "Your proposal (#{options[:funding_duration]} months)"] if
        options[:funding_duration]
    end

    def filter_params
      model.permit(:duration, :eligibility)
    end

    def clear_filters
      if filter_params.empty?
        '<a class="blue js-show-modal">Add filter</a>'
      else
        [
          '<a class="blue js-show-modal">Edit</a>',
          link_to('Clear filters', funds_path(@proposal))
        ].join(' • ')
      end
    end

    def active_filters
      return 'None' if filter_params.empty?
      filter_params.to_h.map { |k, v| "#{k}:#{v}" }.join(', ')
    end

    def query_path
      @url || funds_path(@proposal)
    end
end
