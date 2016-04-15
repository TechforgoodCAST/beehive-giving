class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    mail(to: @user.user_email, subject: 'Welcome to Beehive!')
  end

  def password_reset(user)
    @user = user
    mail(to: @user.user_email, subject: 'Reset your password - Beehive')
  end

  def request_access(organisation, user)
    @organisation = organisation
    @user = user
    mail(to: AdminUser.first.email, subject: "#{@user.first_name} has requested access to #{@organisation.name}")
  end

  def notify_unlock(user)
    @user = user
    mail(to: @user.user_email, subject: 'You have been granted access to your organisation')
  end
  
end
