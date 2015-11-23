# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def welcome
    UserMailer.welcome_email(User.first)
  end

  def password
    UserMailer.password_reset(User.first)
  end

  def admin_summary
    UserMailer.admin_summary(AdminUser.first)
  end

end
