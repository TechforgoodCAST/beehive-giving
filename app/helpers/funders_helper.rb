module FundersHelper

  def funder_card_cta_button_copy(recipient, funder)
    classes = 'uk-width-1-1 uk-button uk-button-large uk-button-primary'

    if recipient.eligible?(funder)
      content_tag(:a, link_to('Apply', '#', class: classes))
    elsif !recipient.eligible?(funder) && recipient.questions_remaining?(funder)
      content_tag(:a, link_to('Check eligibility', recipient_eligibility_path(funder), class: classes))
    elsif !recipient.eligible?(funder) && recipient.eligibility_count(funder) > 0
      'Why ineligible?'
    else
      content_tag(:a, link_to('Browse', recipient_comparison_path(funder), class: classes))
    end
  end

  def percentage(percent, total)
    (percent.to_d / total.to_d).round(1)
  end

end
