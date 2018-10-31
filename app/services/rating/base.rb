module Rating
  module Base
    def initialize(assessment_id, reason)
      @assessment_id = assessment_id
      @reason = reason
    end

    def indicator
      {
        'avoid'    => 'red',
        'unclear'  => 'yellow',
        'approach' => 'green'
      }[@reason['rating']] || 'grey'
    end

    def link; end

    def messages
      @reason['reasons']&.map do |r|
        send(r['id'], r['fund_value'], r['proposal_value'])
      end&.join(' • ')
    end
  end
end
