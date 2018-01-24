module Rating
  module Base
    attr_reader :assessment

    def initialize(args = {})
      @assessment = args[:assessment]
    end

    def colour
      { INELIGIBLE => 'red', ELIGIBLE => 'green' }[state] || 'grey'
    end

    def message
      { INELIGIBLE => ineligible_message, ELIGIBLE => eligible_message }[state]
    end

    def status
      { INELIGIBLE => 'Ineligible', ELIGIBLE => 'Eligible' }[state] || '-'
    end

    def title
      raise_not_implemented(__method__)
    end

    protected

      def state
        raise_not_implemented(__method__)
      end

    private

      def ineligible_message
        raise_not_implemented(__method__)
      end

      def eligible_message
        raise_not_implemented(__method__)
      end

      def raise_not_implemented(method)
        raise NotImplementedError,
              "#{self.class} cannot respond to method: #{method}"
      end
  end
end
