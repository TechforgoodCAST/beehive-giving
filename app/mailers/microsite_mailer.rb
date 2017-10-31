class MicrositeMailer < ApplicationMailer
  def results(email, funder, assessment)
    @funder = funder
    @assessment = assessment
    mail(to: email, subject: "[Results] Should you apply to #{@funder.name}?")
  end
end
