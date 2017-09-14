module ApplicationHelper
  def v2_stylesheet # TODO: remove @ v2
    v2_layout? ? 'v2/' : ''
  end

  def v2_layout? # TODO: remove @ v2
    permitted = {
      articles: %i[index show],
      errors: %i[not_found gone internal_server_error],
      funds: %i[index themed],
      pages: %i[about faq forfunders privacy terms],
      password_resets: %i[new create edit update],
      public_funds: %i[index show],
      signup: %i[user create_user]
    }
    controller = params[:controller].to_sym
    action = params[:action].to_sym

    permitted.key?(controller) && permitted[controller].include?(action)
  end
end
