require 'rails_helper'

describe Request do
  subject { build(:request) }

  it('belongs to Recipient') { assoc(:recipient, :belongs_to) }

  it('belongs to Fund') { assoc(:fund, :belongs_to) }

  it { is_expected.to be_valid }

  it '#recipient required' do
    subject.recipient = nil
    expect(subject).not_to be_valid
  end

  it '#fund required' do
    subject.fund = nil
    expect(subject).not_to be_valid
  end

  it 'must be unique to recipient and fund' do
    subject.save!
    duplicate = subject.dup
    duplicate.valid?
    expect_error(:fund, 'only one request per fund / recipient', duplicate)
  end
end