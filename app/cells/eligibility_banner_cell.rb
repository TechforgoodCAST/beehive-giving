class EligibilityBannerCell < Cell::ViewModel
  def show
    return if model.eligible_status(options[:fund]&.slug).negative?
    render locals: { fund: options[:fund] }
  end

  private

    def ineligible_because(key)
      eligibility = model.eligibility[options[:fund]&.slug].all_values_for(key)
      return unless eligibility[0]
      eligibility[0]['eligible'] == false
    end
end
