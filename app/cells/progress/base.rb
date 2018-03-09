module Progress
  class Base
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper

    def initialize(args = {})
      @assessment = args[:assessment]
      @position   = args[:position]

      @status   = args[:status] # TODO: remove
      @proposal = args[:proposal] # TODO: remove
      @fund     = args[:fund] # TODO: remove
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

    def eligibility_status
      @assessment&.eligibility_status
    end

    def revealed
      @assessment&.revealed
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
