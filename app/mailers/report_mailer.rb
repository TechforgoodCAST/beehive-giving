class ReportMailer < ApplicationMailer
  def notify(proposal)
    @collection = proposal.collection
    @proposal = proposal
    @user = proposal.user

    subject = "Funder report ##{@proposal.id} for #{@collection.name} [Beehive]"

    mail(to: @user.email, subject: subject)
  end
end
