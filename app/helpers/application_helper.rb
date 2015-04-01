module ApplicationHelper
  def current_user_should_render_feedback?
    unless content_for?(:signup)
      logged_in? && (current_user.feedbacks.count == 0)
    end
  end

  def current_user_has_closed_feedback?
    if current_user.sign_in_count < 3
      true
    else
      cookies['_BHfeedbackClose'].present?
    end
  end

  def curent_user_should_show_profile_prompt?

  end
end
