# Preview all emails at http://localhost:3000/rails/mailers/eligibilty_mailer
class EligibiltyMailerPreview < ActionMailer::Preview
  def notify_funder
    EligibiltyMailer.notify_funder(Recipient.first, Funder.first)
  end
end
