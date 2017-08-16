module ApplicationHelper
  def v2_stylesheet # TODO: remove @ v2
    %w[signup].include?(params[:controller]) ? 'v2/' : ''
  end

  def v2_layout? # TODO: remove @ v2
    %w[signup].include?(params[:controller]) &&
      %w[user create_user].include?(params[:action])
  end
end
