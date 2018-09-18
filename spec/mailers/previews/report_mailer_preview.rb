class ReportMailerPreview < ActionMailer::Preview
  def notify
    proposal = Proposal.new(
      id: 12345,
      access_token: 'secret',
      collection: Funder.new(name: 'Esmée Fairbairn Foundation'),
      user: User.new(email: 'email@ngo.org', first_name: 'John')
    )

    ReportMailer.notify(proposal)
  end
end
