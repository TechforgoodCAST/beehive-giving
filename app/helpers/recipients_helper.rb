module RecipientsHelper

  # def recipients_navbar_my_nonprofit_active
  #   current_page?(recipient_profiles_path(current_user.organisation)) ||
  #   current_page?(edit_recipient_profile_path(current_user.organisation, current_user.organisation.profiles.first)) ||
  #   current_page?(recipient_eligibility_path)
  # end

  def funder_card_cta_button_copy(recipient, funder)
    # Must run Recipient.joins(:users).find_each { |r| r.check_eligibilities } before
    classes = 'uk-width-1-1 uk-button uk-button-primary uk-button-large'
    if recipient.load_recommendation(funder).eligibility
      if recipient.eligible?(funder)
        content_tag(:a, link_to('Apply', recipient_apply_path(funder), class: classes))
      else
        content_tag(:a, link_to('Why ineligible?', recipient_eligibility_path(funder), class: classes))
      end
    else
      content_tag(:a, link_to('Check eligibility', recipient_eligibility_path(funder), class: classes))
    end
  end

  def redacted_insights
    [
      'An epic insight of magnificence!',
      'A golden nugget of knowledge.',
      'That critical fact for decision making.',
      'A morsel to muse over.',
      'That timesaving tip.',
      'A curious connection.',
      'Awesome advice.'
    ].sample
  end

  def redacted_actions
    [
      'More info',
      'Show me more'
    ].sample
  end

  def percentage(percent, total)
    "#{((percent.to_d / total.to_d).round(3) * 100)}%"
  end

end
