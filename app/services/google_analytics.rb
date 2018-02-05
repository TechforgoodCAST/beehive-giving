# TODO: https://github.com/railslove/rack-tracker/pull/103
class GoogleAnalytics < Rack::Tracker::GoogleAnalytics
  def render
    template = Rails.root.join('app', 'views', 'shared', 'google_analytics.erb')
    Tilt.new(template).render(self)
  end
end
