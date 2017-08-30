class EligibilityBannerCell < Cell::ViewModel
  def show
    return unless model.eligibility.key?(options[:fund]&.slug)
    render locals: { fund: options[:fund] }
  end

  def location
    return unless model.eligibility.dig(options[:fund]&.slug, 'location')
    render locals: {}
  end

  def amount
    return unless model.eligibility.dig(options[:fund]&.slug, 'amount')
    render locals: {}
  end

  def org_type
    return unless model.eligibility.dig(options[:fund]&.slug, 'org_type')
    render locals: { org_type: ORG_TYPES[model.recipient.org_type + 1][2] }
  end

  def quiz
    return unless model.eligibility.dig(options[:fund]&.slug, 'quiz')
    render locals: { count_failing: model.eligibility[options[:fund]&.slug]['quiz']['count_failing'] }
  end

  def eligible
    return unless model.eligible?(options[:fund]&.slug)
    render locals: {fund: options[:fund]}
  end

end
