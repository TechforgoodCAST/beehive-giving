class Topsis
  # https://en.wikipedia.org/wiki/TOPSIS

  WEIGHTS = {
    'theme'    => 10,
    'location' => 9,
    'quiz'     => 7,
    'org_type' => 5,
    'amount'   => 2,
    'duration' => 2
  }.freeze

  def initialize(hash)
    raise "#{self.class} not initialized with Hash" unless hash.is_a? Hash
    raise 'Empty Hash supplied' if hash.empty?
    hash = only_with_scores(hash)
    @decision_matrix = decision_matrix(hash, standardisation(hash))
  end

  def rank
    best = distance_from(solution(:max))
    worst = distance_from(solution(:min))
    @decision_matrix.map do |slug, _|
      [slug, worst[slug] / catch_zero((best[slug] + worst[slug]))]
    end.to_h
  end

  private

    def only_with_scores(data)
      data.map do |slug, hash|
        [slug, hash.except('total').select{ |k, v| v.has_key?('score') }]
      end.to_h
    end

    def decision_matrix(data, standardised)
      data.map do |slug, hash|
        [slug, weighted_normalised(hash, standardised)]
      end.to_h
    end

    def weighted_normalised(hash, standardised)
      hash.except('total').map do |k, v|
        [k, (v['score'] / catch_zero(standardised[k])) * WEIGHTS[k]]
      end.to_h
    end

    def standardisation(hash)
      WEIGHTS.keys.map do |k|
        [
          k,
          Math.sqrt(
            hash.all_values_for(k)
                .pluck('score')
                .reject{ |i| i.nil? }
                .map { |i| i**2 }
                .reduce(:+).to_f
          )
        ]
      end.to_h
    end

    def catch_zero(float)
      float.zero? ? Float::INFINITY : float
    end

    def distance_from(criteria)
      @decision_matrix.map do |slug, hash|
        [slug, hash.map { |k, v| (v - criteria[k])**2 }.reduce(&:+)**0.5]
      end.to_h
    end

    def solution(distance)
      WEIGHTS.map do |k, _|
        [k, @decision_matrix.all_values_for(k).send(distance)]
      end.to_h
    end
end
