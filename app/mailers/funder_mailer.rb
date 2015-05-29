class FunderMailer < ApplicationMailer

  def weekly_summary_email(funder)
    @funder = funder
    @unlocks = RecipientFunderAccess.where("funder_id = ?", funder.id).group_by_week(:created_at, last: 1).count

    mail(to: (@funder.users.any? ? @funder.users.first.user_email : 'support@beehivegiving.org'), subject: "Beehive weekly summary")
  end

  def eligible_email(recipient, funder)
    # refactor, dry-er way?
    @recipient = recipient
    @funder = funder
    @profile = @recipient.profiles.first

    mail(to: ('support@beehivegiving.org, anna@thefoundation.org'), subject: "#{@recipient.name} is eligible for your support")
    # mail(to: (@funder.users.any? ? @funder.users.first.user_email : 'support@beehivegiving.org'), subject: "#{@recipient.name} is not eligible for your support")
  end

  def not_eligible_email(recipient, funder)
    # refactor, dry-er way?
    @recipient = recipient
    @funder = funder
    @profile = @recipient.profiles.first

    mail(to: ('support@beehivegiving.org, anna@thefoundation.org'), subject: "#{@recipient.name} is eligible for your support")
    # mail(to: (@funder.users.any? ? @funder.users.first.user_email : 'support@beehivegiving.org'), subject: "#{@recipient.name} is not eligible for your support")
  end

end
