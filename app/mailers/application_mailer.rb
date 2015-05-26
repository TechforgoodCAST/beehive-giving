class ApplicationMailer < ActionMailer::Base
  default from: "\"Beehive\" <support@beehivegiving.org>"
  layout 'mailer'
end
