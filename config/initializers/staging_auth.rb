Rails.application.configure do
  # Restrict access with HTTP Basic Auth for staging environments
  if ENV['STAGING_AUTH'].present?
    config.force_ssl = false

    config.middleware.use Rack::Auth::Basic do |username, password|
      ENV['STAGING_AUTH'].split(';').any? do |pair|
        pair.split(':') == [username, password]
      end
    end
  end
end
