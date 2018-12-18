module ReportsHelper
  def amount_sought(proposal = @proposal)
    opts = { unit: '£', precision: 0 }
    min = number_to_currency(proposal.min_amount, opts)
    max = number_to_currency(proposal.max_amount, opts)
    "Between #{min} and #{max}"
  end

  def created_by(recipient = @proposal.recipient)
    recipient.individual? ? 'an individual' : recipient.name
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

  def recipient_name(recipient = @proposal.recipient)
    if recipient.individual?
      recipient_type(recipient)
    else
      recipient.name
    end
  end

  def report_button(report)
    if report.private?
      classes = 'disabled btn btn-wide grey bg-ice border-mist'
      tag.a('View full report', disabled: true, class: classes)
    else
      classes = 'btn btn-wide blue bg-light-blue border-pale-blue'
      link_to('View full report', report_path(report), class: classes)
    end
  end

  def spot_mistake_form_url(path)
    'https://docs.google.com/forms/d/e/1FAIpQLSeOkkh1Ecb43lOQd2wDe_3ueLVpX46u' \
    'NxjngJRIV2VpSUKMag/viewform?usp=pp_url&entry.1646333123=https://www.beeh' \
    "ivegiving.org" + path
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
