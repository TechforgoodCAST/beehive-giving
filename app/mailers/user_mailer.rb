class UserMailer < ActionMailer::Base
  default from: "\"Beehive\" <support@beehivegiving.org>"
  def welcome_email(user)
    @user = user
    mail(to: @user.user_email, subject: 'Welcome to Beehive!')
  end

  def password_reset(user)
    @user = user
    mail(to: @user.user_email, subject: 'Reset your password - Beehive')
  end
end
