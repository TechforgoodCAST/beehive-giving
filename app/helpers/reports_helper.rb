module ReportsHelper
  def amount_sought(proposal = @proposal)
    opts = { unit: '£', precision: 0 }
    min = number_to_currency(proposal.min_amount, opts)
    max = number_to_currency(proposal.max_amount, opts)
    "Between #{min} and #{max}"
  end

  def location_description(proposal = @proposal)
    "#{proposal.geographic_scale.capitalize} - " \
    "#{proposal.countries.pluck(:name).to_sentence}"
  end

  def recipient_type(recipient = @proposal.recipient)
    if recipient.description.present?
      "#{recipient.category_name} - #{recipient.description}"
    else
      recipient.category_name
    end
  end

  def support_type(proposal = @proposal)
    if proposal.support_details.present?
      "#{proposal.category_name} - #{proposal.support_details}"
    else
      proposal.category_name
    end
  end

  def themes_description(proposal = @proposal)
    proposal.themes.pluck(:name).join(' • ')
  end
end
