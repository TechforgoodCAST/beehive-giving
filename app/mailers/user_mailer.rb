class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.user_email, subject: 'Welcome to Beehive!')
  end

  def password_reset(user)
    @user = user
    mail(to: @user.user_email, subject: 'Reset your password - Beehive')
  end

  def notify_funder(profile)
    @profile = profile
    mail(to: 'anna@forwardfoundation.org.uk, suraj@forwardfoundation.org.uk', subject: "#{@profile.organisation.name} has just submitted a profile")
  end
end
