module Mixpanelable
  MIXPANEL = Mixpanel::Tracker.new(ENV['MIXPANEL_TOKEN'])

  def mixpanel_identify(user, request, opts = {})
    return if user.nil?
    mixpanel_params = user_params(user)
    mixpanel_alias(user, request)
    MIXPANEL.people.set(user.id, mixpanel_params.merge(opts), request.remote_ip)
  end

  private

    def mixpanel_cookies(request)
      mp_cookies = request.cookies["mp_#{ENV['MIXPANEL_TOKEN']}_mixpanel"]
      mp_cookies ? JSON.parse(mp_cookies) : {}
    end

    def mixpanel_alias(user, request)
      distinct_id = mixpanel_cookies(request)['distinct_id']
      MIXPANEL.alias(user.id, distinct_id: distinct_id) if distinct_id
    end

    def user_params(user)
      {
        '$first_name'   => user.first_name,
        '$last_name'    => user.last_name,
        '$email'        => user.email,
        '$last_login'   => user.last_seen.as_json,
        '$created'      => user.created_at.as_json,
        'Updated'       => user.updated_at.as_json,
        'Sign in count' => user.sign_in_count
      }
    end
end
