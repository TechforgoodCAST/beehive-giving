class MicrositeMailerPreview < ActionMailer::Preview
  def results
    funder = Funder.new(name: 'Funder Name', slug: 'funder-name')
    attempt = Attempt.new(id: 1, access_token: '12345')
    MicrositeMailer.results('email@example.com', funder, attempt)
  end
end
