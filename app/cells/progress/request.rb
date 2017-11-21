module Progress
  class Request < Base
    def initialize(*args)
      super
    end

    def label
      'Update fund details'
    end

    def indicator
      "bg-blue #{@position}"
    end

    def message
      link_to('Request', url_helpers.requests_path(fund: @fund), method: :post, class: 'fs15 btn white bg-blue shadow')
    end

    def highlight
      'bg-light-blue'
    end
  end
end
