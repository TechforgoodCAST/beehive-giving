module RecipientsHelper

  def fund_card_cta_button_copy(fund)
    classes = 'uk-width-1-1 uk-button uk-button-primary uk-button-large'
    if @proposal.recommendation(fund).eligibility
      if @proposal.eligible?(fund)
        content_tag(:a, link_to('Apply', fund_apply_path(fund), class: classes))
      else
        content_tag(:a, link_to('Why ineligible?', fund_eligibility_path(fund), class: classes))
      end
    else
      content_tag(:a, link_to('Check eligibility', fund_eligibility_path(fund), class: classes))
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

  def score_to_match_copy(score, scale = 1)
    {
      'Not enough data' => 0,
      'Very poor'       => 0.2,
      'Poor'            => 0.4,
      'Fair'            => 0.6,
      'Good'            => 0.8,
      'Excellent'       => 1.0
    }.each do |k, v|
      return content_tag(:strong, k, class: k.downcase.to_s.sub(' ', '-')) if score <= (v * scale)
    end
  end

  def scramble_name(name)
    name.chars.map { |c| c.sub(/\w/, ('a'..'z').to_a.sample) }.join.capitalize
  end

  def scramble_recommendations
    content_tag(:strong, scramble_name(%w[Poor Excellent].sample), class: 'redacted muted')
  end

  def render_recommendation(fund, score, scale = 1)
    if @proposal.show_fund(fund)
      score_to_match_copy(@proposal.recommendation(fund)[score.to_s], scale)
    else
      scramble_recommendations
    end
  end

  def percentage(percent, total)
    "#{((percent.to_d / total.to_d).round(3) * 100)}%"
  end

end
