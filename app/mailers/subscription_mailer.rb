class SubscriptionMailer < ApplicationMailer
  def deactivated(user)
    @user = user
    mail(to: @user.email, subject: 'Subscription Expired - Beehive')
  end
end
