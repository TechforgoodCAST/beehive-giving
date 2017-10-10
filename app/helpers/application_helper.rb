module ApplicationHelper
  def v2_stylesheet # TODO: remove @ v2
    v2_layout? ? 'v2/' : ''
  end

  def v2_layout? # TODO: remove @ v2
    permitted = {
      accounts: %i[subscription],
      articles: %i[index show],
      charges: %i[new thank_you],
      eligibilities: %i[new],
      enquiries: %i[new],
      errors: %i[not_found gone internal_server_error],
      # feedback: %i[edit new],
      funds: %i[index themed show],
      pages: %i[about faq forfunders privacy terms], # preview?
      password_resets: %i[new create edit update],
      proposals: %i[index], # edit new update
      public_funds: %i[index show themed],
      recipients: %i[edit update],
      # sessions: %i[new],
      signup: %i[user create_user], # funder, granted_access, unauthorised
      # signup_proposals: %i[edit new],
      # signup_recipients: %i[edit new],
      users: %i[edit update],
    }
    controller = params[:controller].to_sym
    action = params[:action].to_sym

    permitted.key?(controller) && permitted[controller].include?(action)
  end
end
