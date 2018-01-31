module Progress
  class Base
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    def initialize(args = {})
      @position = args[:position]
      @proposal = args[:proposal]
      @fund     = args[:fund]
      @status   = args[:status]
    end

    def label
      raise_not_implemented(__method__)
    end

    def indicator
      raise_not_implemented(__method__)
    end

    def message
      raise_not_implemented(__method__)
    end

    def highlight
      raise_not_implemented(__method__)
    end

    private

      def raise_not_implemented(method)
        raise NotImplementedError,
              "#{self.class} cannot respond to method: #{method}"
      end

      def url_helpers
        Rails.application.routes.url_helpers
      end

      def link_opts
        { 'data-turbolinks' => false }
      end
  end
end
