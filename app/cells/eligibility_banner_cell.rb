class EligibilityBannerCell < Cell::ViewModel
  def show
    return unless model.eligibility.key?(options[:fund]&.slug)
    render locals: { fund: options[:fund] }
  end

  private

    def ineligible_because(key)
      model.eligibility[options[:fund]&.slug][key] == false
    end
end
