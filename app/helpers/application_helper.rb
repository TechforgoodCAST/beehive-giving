module ApplicationHelper
  def v2_stylesheet # TODO: remove @ v2
    v2_layout? ? 'v2/' : ''
  end

  def v2_layout? # TODO: remove @ v2
    %w[pages signup].include?(params[:controller]) &&
      %w[about user create_user].include?(params[:action])
  end
end
