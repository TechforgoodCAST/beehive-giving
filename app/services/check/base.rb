module Check
  module Base
    attr_reader :assessment

    def call(assessment)
      @assessment = assessment
      validate(@assessment)
    end

    private

      def validate(assessment)
        raise ArgumentError, 'Invalid Assessment' unless
          assessment.is_a?(Assessment)
      end
  end
end
