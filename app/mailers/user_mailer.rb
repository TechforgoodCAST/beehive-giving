class UserMailer < ActionMailer::Base
  default from: "beehive@forwardfoundation.org.uk"
  def welcome_email(organisation)
    @organisation = organisation
    mail(to: @organisation.contact_email, subject: 'Welcome to Beehive!')
  end

  def password_reset(user)
    @user = user
    mail(to: @user.user_email, subject: 'Password Reset - Beehive')
  end
end
