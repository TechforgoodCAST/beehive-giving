module Rating
  class Each
    attr_reader :ratings

    def initialize(assessment)
      @ratings = assessment.reasons.map do |check, reason|
        rating = check.sub('Check', 'Rating').constantize
        rating.new(assessment.id, reason)
      end
    end
  end
end
