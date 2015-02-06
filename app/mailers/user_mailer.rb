class UserMailer < ActionMailer::Base
  default from: "support@beehivegiving.org"
  def welcome_email(user)
    @user = user
    mail(to: @user.user_email, subject: 'Welcome to Beehive!')
  end

  def password_reset(user)
    @user = user
    mail(to: @user.user_email, subject: 'Password Reset - Beehive')
  end
end
