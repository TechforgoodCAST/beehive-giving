module Check
  module Base
    attr_reader :assessment

    def call(assessment)
      @assessment = assessment
      validate(@assessment)
    end

    def eligible(bool) # TODO: deprecated
      { 'eligible' => bool }
    end

    def validate_call(proposal, fund) # TODO: deprecated
      raise 'Invalid Proposal' unless proposal.is_a? Proposal
      raise 'Invalid Fund' unless fund.is_a? Fund
    end

    private

      def validate(assessment)
        raise ArgumentError, 'Invalid Assessment' unless
          assessment.is_a?(Assessment)
      end
  end
end
