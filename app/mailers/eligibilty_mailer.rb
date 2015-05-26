class EligibiltyMailer < ApplicationMailer
  def notify_funder(recipient, funder)
    @recipient = recipient
    @funder = funder

    mail(to: (@funder.users.any? ? @funder.users.first.user_email : 'support@beehivegiving.org'), subject: "#{@recipient.name} is eligible for your support")
  end
end
