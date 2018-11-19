require 'rails_helper'

describe ReportMailer do
  context '#notify(proposal)' do
    let(:mail) { ReportMailer.notify(proposal) }
    let(:proposal) { create(:proposal) }

    it 'renders headers' do
      collection = proposal.collection
      subject = "Funder report ##{proposal.id} for #{collection.name} [Beehive]"
      expect(mail.subject).to eq(subject)
      expect(mail.to).to eq([proposal.user.email])
      expect(mail.from).to eq(['support@beehivegiving.org'])
    end

    context 'renders body' do
      let(:body) { mail.body.encoded }

      it 'with report link' do
        expect(body).to have_link(
          'View full report',
          href: report_url(proposal, t: proposal.access_token)
        )
      end

      it 'with reports link' do
        expect(body).to have_link(
          'All my reports',
          href: sign_in_lookup_url(email: proposal.user.email)
        )
      end

      it 'with upgrade link' do
        expect(body).to have_link(
          'keep the report Private',
          href: new_charge_url(proposal)
        )
      end
    end
  end
end
