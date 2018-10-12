module Check
  module Base
    attr_reader :assessment
    attr_accessor :reasons

    def initialize
      @reasons = Set.new
    end

    def call(assessment)
      @assessment = assessment
      validate(@assessment)
    end

    private

      def build_reason(status, reasons, assessment: @assessment)
        rating = {
          nil        => 'unclear',
          ELIGIBLE   => 'approach',
          INCOMPLETE => 'unclear',
          INELIGIBLE => 'avoid'
        }[status]

        raise('Invalid rating') if rating.nil?

        assessment.reasons[self.class.to_s] = {
          rating: rating, reasons: reasons
        }
      end

      def check_limit(amount, operator, limit)
        return unless assessment.fund[limit]

        assessment.proposal[amount].send(operator, assessment.fund[limit])
      end

      def validate(assessment)
        raise ArgumentError, 'Invalid Assessment' unless
          assessment.is_a?(Assessment)
      end
  end
end
