module OpportunitiesHelper
  def breakdown(hash)
    @total = hash.sum(&:last).to_f
    {
      'Can apply' => percentage(hash['approach']),
      'Unclear' => percentage(hash['unclear']),
      "Shouldn't apply" => percentage(hash['avoid'])
    }
  end

  private

    def percentage(value, total = @total)
      number_to_percentage(((value || 0) / total) * 100, precision: 0)
    end
end
