class FilterCell < Cell::ViewModel
  def show
    @proposal = options[:proposal]
    render
  end

  private

    def filter_params
      model.permit(:duration, :eligibility)
    end

    def clear_filters
      return if filter_params.empty?
      link_to('Clear all filters', funds_path(@proposal), class: 'fs15')
    end

    def active_filters
      return '<a class="blue bold">Add filter</a>' if filter_params.empty?
      filter_params.to_h.map { |k, v| "#{k}:#{v}" }.join(', ')
    end
end
