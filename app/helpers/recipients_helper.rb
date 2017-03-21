module RecipientsHelper
  TAG_CLASSES = %w(uk-button uk-button-small uk-button-primary invert
                   uk-margin-small-bottom).freeze

  def fund_card_eligibility_text(fund)
    case @proposal.eligibility_for(fund)
    when 0
      link_to('Ineligible', eligibility_proposal_fund_path(@proposal, fund), class: 'very-poor')
    when 1
      link_to('Eligible', eligibility_proposal_fund_path(@proposal, fund), class: 'excellent')
    else
      link_to('Check', eligibility_proposal_fund_path(@proposal, fund), class: 'primary')
    end
  end

  def fund_card_cta_button_copy(fund)
    classes = 'uk-width-1-1 uk-button uk-button-primary uk-button-large'
    case @proposal.eligibility_for(fund)
    when 0
      link_to('Why ineligible?', eligibility_proposal_fund_path(@proposal, fund), class: classes)
    when 1
      link_to('Apply', apply_proposal_fund_path(@proposal, fund), class: classes)
    else
      link_to('Check eligibility', eligibility_proposal_fund_path(@proposal, fund), class: classes)
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
      'Not enough data' => 0,   'Very poor' => 0.2,
      'Poor'            => 0.4, 'Fair'      => 0.6,
      'Good'            => 0.8, 'Excellent' => 1.0
    }.each do |k, v|
      return content_tag(:strong, k, class: k.downcase.to_s.sub(' ', '-')) if
        score <= (v * scale)
    end
  end

  def scramble_name(name)
    name.chars.map { |c| c.sub(/\w/, ('a'..'z').to_a.sample) }.join.capitalize
  end

  def scramble_recommendations
    content_tag(:strong, scramble_name(%w(Poor Excellent).sample),
                class: 'redacted muted')
  end

  def render_recommendation(fund, score, scale = 1)
    if @proposal.show_fund?(fund)
      score_to_match_copy(@proposal.recommendation(fund)[score.to_s], scale)
    else
      scramble_recommendations
    end
  end

  def percentage(percent, total)
    "#{((percent.to_d / total.to_d).round(3) * 100)}%"
  end

  def render_tags(fund)
    safe_join fund.tags.sort.map { |t|
      link_to t, tag_proposal_funds_path(@proposal, t.parameterize),
              class: TAG_CLASSES # TODO: refactor
    }, ' '
  end

  def render_redacted_tags(fund)
    link_to('Upgrade to see funding themes',
            account_upgrade_path(@recipient),
            class: 'uk-text-bold') +
      safe_join(['</br>'.html_safe]) +
      safe_join(fund.tags.sort.map do |t|
        link_to scramble_name(t.parameterize), # TODO: refactor
                account_upgrade_path(@recipient), class: TAG_CLASSES +
                                 %w(redacted uk-margin-small-top)
      end, ' ')
  end

  def render_tag_list(fund)
    return unless fund.tags?
    content_tag :div, class: 'uk-margin-top' do
      if @proposal.show_fund?(fund)
        render_tags(fund)
      else
        render_redacted_tags(fund)
      end
    end
  end
end
