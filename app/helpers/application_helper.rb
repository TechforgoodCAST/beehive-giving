module ApplicationHelper
  def current_user_should_render_feedback?
    logged_in? && (current_user.feedbacks.count < 1 || current_user.sign_in_count > 1)
  end

  def current_user_has_closed_feedback?
    cookies['_BHfeedbackClose'].present?
  end

  def curent_user_should_show_profile_prompt?
        
  end
end
