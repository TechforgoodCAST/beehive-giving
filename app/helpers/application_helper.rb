module ApplicationHelper
  def v2_stylesheet? # TODO: remove @ v2
    %w[signup].include?(params[:controller]) ? 'v2/' : ''
  end
end
