class OrganisationMailer < ActionMailer::Base
  default from: "from@example.com"
  def welcome_email(organisation)
    @organisation = organisation
    mail(to: @organisation.contact_email, subject: 'Welcome to Beehive!')
  end
end
