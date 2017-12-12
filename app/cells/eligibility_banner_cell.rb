class EligibilityBannerCell < Cell::ViewModel
  def show
    return unless model.eligibility.key?(options[:fund]&.slug)
    render locals: { fund: options[:fund] }
  end

  def location
    return '-' unless model.eligibility.dig(options[:fund]&.slug, 'location')
    render locals: { location: options[:fund].geo_area.name, eligible: options[:eligible] }
  end

  def amount
    return '-' unless model.eligibility.dig(options[:fund]&.slug, 'amount')
    return '-' if options[:eligible] && !options[:fund].amount_desc
    render locals: { eligible: options[:eligible], message: options[:fund].amount_desc }
  end

  def org_type
    return '-' unless model.eligibility.dig(options[:fund]&.slug, 'org_type')
    fund_org_types = options[:fund].permitted_org_types.map{ |o| ORG_TYPES[o + 1][2] }
    render locals: { org_type: ORG_TYPES[model.recipient.org_type + 1][2], fund_org_types: fund_org_types, eligible: options[:eligible]  }
  end

  def funding_type
    return '-' unless model.eligibility.dig(options[:fund]&.slug, 'funding_type')
    fund_type = FUNDING_TYPES[model.funding_type][0].truncate_words(2, omission: '').downcase
    render locals: { message: fund_type, eligible: options[:eligible]  }
  end

  def org_income
    return '-' unless model.eligibility.dig(options[:fund]&.slug, 'org_income')
    return '-' if options[:eligible] && !options[:fund].org_income_desc
    render locals: { eligible: options[:eligible], message: options[:fund].org_income_desc }
  end

  def quiz
    return '-' unless model.eligibility.dig(options[:fund]&.slug, 'quiz')
    return '-' if options[:eligible]
    render locals: { count_failing: model.eligibility[options[:fund]&.slug]['quiz']['count_failing'], eligible: options[:eligible] }
  end

  def eligible
    return unless model.eligible?(options[:fund]&.slug)
    render locals: { fund: options[:fund] }
  end
end
