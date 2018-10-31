module GenerateToken
  extend ActiveSupport::Concern

  included do
    def generate_token(column)
      loop do
        new_token = SecureRandom.urlsafe_base64
        old_token = send(column)

        send("#{column}=", new_token)
        break if new_token != old_token
      end
    end
  end
end
