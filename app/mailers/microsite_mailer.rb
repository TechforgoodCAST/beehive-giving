class MicrositeMailer < ApplicationMailer
  def results(email, funder, attempt)
    @funder = funder
    @attempt = attempt
    mail(to: email, subject: "[Results] Should you apply to #{@funder.name}?")
  end
end
