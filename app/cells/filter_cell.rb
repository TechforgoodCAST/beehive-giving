include ActionView::Helpers::FormOptionsHelper

class FilterCell < Cell::ViewModel
  def show
    @proposal = options[:proposal]
    @request_path = options[:request_path]
    render
  end

  private

    def country_options
      options_from_collection_for_select(
        Country.order(priority: :desc).all, :alpha2, :name, model[:country]
      )
    end

    def eligibility_options
      options_for_select(
        opts(['All', 'Eligible', 'Ineligible', 'To check']), model[:eligibility]
      )
    end

    def funding_type_options
      options_for_select(opts(%w[All Capital Revenue]), model[:type])
    end

    def opts(arr)
      arr.map { |opt| [opt, opt.parameterize] }.to_h
    end

    def filter_params
      model.permit(:country, :eligibility, :type)
    end

    def clear_filters
      if filter_params.empty?
        '<a class="blue js-show-modal">Add filter</a>'
      else
        [
          '<a class="blue js-show-modal">Edit</a>',
          link_to('Clear filters', query_path)
        ].join(' • ')
      end
    end

    def active_filters
      return 'None' if filter_params.empty?
      filter_params.to_h.map { |k, v| "#{k}:#{v}" }.join(', ')
    end

    def query_path
      @request_path || funds_path(@proposal)
    end
end
