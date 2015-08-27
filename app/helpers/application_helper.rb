module ApplicationHelper

  def current_user_should_render_feedback?
    unless content_for?(:signup) || current_page?(controller: 'feedback', action: 'new')
      logged_in? && (current_user.feedbacks.count == 0)
    end
  end

  def current_user_should_render_welcome_modal?
    @recipient.profiles.count < 1
  end

end
