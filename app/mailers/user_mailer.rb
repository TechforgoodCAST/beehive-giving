class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    mail(to: @user.user_email, subject: 'Welcome to Beehive!')
  end

  def password_reset(user)
    @user = user
    mail(to: @user.user_email, subject: 'Reset your password - Beehive')
  end

  def admin_summary(admin)
    @admin = admin
    @subject = "#{Date.today.strftime("#{Date.today.day.ordinalize} %b %y'")} - Beehive Update"

    def get_data(model, column='created_at')
      model.group_by_day(column, range: 7.days.ago..Date.today).count.values.to_a.reverse
    end

    @users = get_data(User)
    @recipients = get_data(Recipient.joins(:users), 'users.created_at')
    @profiles = get_data(Profile)

    mail(to: @admin.email, subject: @subject)
  end

end
