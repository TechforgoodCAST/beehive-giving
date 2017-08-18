class EligibilityBannerCell < Cell::ViewModel
  def show
    return unless model.eligibility.key?(options[:fund]&.slug)
    render locals: { fund: options[:fund] }
  end

  def location
    render locals: {}
  end

  def amount
    render locals: {}
  end

  def org_type
    render locals: { org_type: ORG_TYPES[model.recipient.org_type + 1][2] }
  end

  def quiz
    render locals: { count_failing: model.eligibility[options[:fund]&.slug]['quiz']['count_failing'] }
  end

  private

    def ineligible_because(key)
      eligibility = model.eligibility[options[:fund]&.slug].all_values_for(key)
      return unless eligibility[0]
      eligibility[0]['eligible'] == false
    end
end
