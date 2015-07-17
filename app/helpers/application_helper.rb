module ApplicationHelper

  def current_user_should_render_feedback?
    unless content_for?(:signup) || current_page?(controller: 'feedback', action: 'new')
      logged_in? && (current_user.feedbacks.count == 0)
    end
  end

  def current_user_should_render_welcome_modal?
    cookies['_BHwelcomeClose'].blank? unless @recipient.profiles.count > 0
  end

  # refactor
  def current_user_should_render_recommendation_modal?
    @recipient.profiles.where(year: Date.today.year).count == 1 unless @recipient.unlocked_funders.count > 0 || cookies['_BHrecommendationClose'].present?
  end

  # refactor
  def current_user_should_render_eligibility_modal?
    @recipient.unlocked_funders.count == 1 if @recipient.questions_remaining?(@recipient.unlocked_funders.first)
  end

end
