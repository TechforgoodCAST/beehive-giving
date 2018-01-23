module Rating
  module Base
    attr_reader :assessment

    def initialize(args = {})
      @assessment = args[:assessment]
    end

    def colour
      { 0 => 'red', 1 => 'green' }[state] || 'grey'
    end

    def message
      '-'
    end

    def status
      { 0 => 'Ineligible', 1 => 'Eligible' }[state] || '-'
    end

    def title
      raise_not_implemented(__method__)
    end

    protected

      def state
        raise_not_implemented(__method__)
      end

    private

      def raise_not_implemented(method)
        raise NotImplementedError,
              "#{self.class} cannot respond to method: #{method}"
      end
  end
end
