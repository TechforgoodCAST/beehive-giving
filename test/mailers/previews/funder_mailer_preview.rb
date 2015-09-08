# Preview all emails at http://localhost:3000/rails/mailers/funder_mailer
class FunderMailerPreview < ActionMailer::Preview

  def weekly_summary_email
    FunderMailer.weekly_summary_email(Funder.first)
  end

  def eligible_email
    FunderMailer.eligible_email(Recipient.first, Funder.first)
  end

  def not_eligible_email
    FunderMailer.not_eligible_email(Recipient.first, Funder.first)
  end

end
