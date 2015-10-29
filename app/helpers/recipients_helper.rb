module RecipientsHelper

  def dup_hash(ary)
    ary.inject(Hash.new(0)) { |h,e| h[e] += 1; h }.select {
      |k,v| v > 0 }.inject({}) { |r, e| r[e.first] = e.last; r }
  end

  def funder_card_cta_button_copy(recipient, funder)
    classes = 'uk-width-1-1 uk-button uk-button-large uk-button-primary'

    # if recipient.eligible?(funder)
    #   content_tag(:a, link_to('Apply', '#', class: classes))
    # elsif !recipient.eligible?(funder) && recipient.questions_remaining?(funder)
    #   content_tag(:a, link_to('Check eligibility', recipient_eligibility_path(funder), class: classes))
    # elsif !recipient.eligible?(funder) && recipient.eligibility_count(funder) > 0
    #   content_tag(:a, link_to('Why ineligible?', '#', class: classes))
    # else
    #   content_tag(:a, link_to('Browse', recipient_comparison_path(funder), class: classes))
    # end

    # Must run Recipient.joins(:users).find_each { |r| r.check_eligibilities } before
    if recipient.load_recommendation(funder).eligibility
      if recipient.eligible?(funder)
        content_tag(:a, link_to('Apply', '#', class: classes))
      else
        content_tag(:a, link_to('Why ineligible?', '#', class: classes))
      end
    else
      content_tag(:a, link_to('Check eligibility', recipient_eligibility_path(funder), class: classes))
    end
  end

  def percentage(percent, total)
    (percent.to_d / total.to_d).round(1)
  end

end
