class SubscriptionMailerPreview < ActionMailer::Preview
  def deactivated
    user = OpenStruct.new(email: 'email@example.com', first_name: 'John')
    SubscriptionMailer.deactivated(user)
  end
end
