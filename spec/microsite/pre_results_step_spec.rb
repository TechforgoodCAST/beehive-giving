require 'rails_helper'

describe PreResultsStep do
  let(:recipient) {}
  let(:assessment) { Assessment.new(recipient: recipient) }

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

  it '#save creates User' do
    subject.email = 'email@example.com'
    subject.save
    expect(User.count).to eq 1
  end

  context 'existing User' do
    let(:user) { create(:user) }

    it '#save updates User' do
      subject.email = user.email
      subject.save
      expect(User.count).to eq 1
    end
  end

  context 'existing Recipient' do
    let(:recipient) { create(:recipient) }

    it '#save associates User' do
      subject.assessment = assessment
      subject.email = 'email@example.com'
      subject.save
      expect(User.last.organisation).to eq recipient
    end
  end

  it '#save updates Assessment' do
    subject.assessment = assessment
    subject.email = 'email@example.com'
    subject.save
    expect(assessment.state).to eq 'results'
  end

  it '#save triggers email' do
    subject.save
    expect(deliveries.count).to eq 1
  end
end
