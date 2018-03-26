require 'rails_helper'

describe PreResultsStep do
  let(:recipient) {}
  let(:funder) { create(:funder, name: 'Funder Name') }
  let(:attempt) { Attempt.new(id: 1, recipient: recipient, funder: funder) }

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
      subject.attempt = attempt
      subject.email = 'email@example.com'
      subject.agree_to_terms = true
      subject.save
      @user = User.last
    end

    it 'sets User#email' do
      expect(@user.email).to eq(subject.email)
    end

    it 'sets User#agree_to_terms' do
      expect(@user.agree_to_terms).to eq(subject.agree_to_terms)
    end

    it 'creates User' do
      expect(User.count).to eq 1
    end

    it 'updates Attempt' do
      expect(attempt.state).to eq 'results'
    end

    context 'existing Recipient' do
      let(:recipient) { create(:recipient) }

      it 'associates User' do
        expect(@user.organisation).to eq(recipient)
      end
    end
  end
end
