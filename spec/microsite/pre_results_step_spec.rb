require 'rails_helper'

describe PreResultsStep do
  let(:recipient) {}
  let(:funder) { create(:funder, name: 'Funder Name') }
  let(:assessment) { Assessment.new(id: 1, recipient: recipient, funder: funder) }

  context '#email' do
    it 'required' do
      subject.email = nil
      is_expected.not_to be_valid
    end

    it 'valid format' do
      subject.email = 'invalid£email.xom'
      is_expected.not_to be_valid
    end
  end

  context 'existing User' do
    let(:user) { create(:user) }

    it '#save updates User' do
      subject.email = user.email
      subject.save
      expect(User.count).to eq 1
    end
  end

  context '#save' do
    before do
      subject.assessment = assessment
      subject.email = 'email@example.com'
      subject.agree_to_terms = true
      subject.save
    end

    it 'creates User' do
      expect(User.count).to eq 1
    end

    it 'updates Assessment' do
      expect(assessment.state).to eq 'results'
    end

    context 'existing Recipient' do
      let(:recipient) { create(:recipient) }

      it 'associates User' do
        expect(User.last.organisation).to eq recipient
      end
    end
  end
end
