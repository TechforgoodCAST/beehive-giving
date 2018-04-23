require 'rails_helper'

describe Answer do
  subject { build(:answer) }

  it('belongs to category') { assoc(:category, :belongs_to, polymorphic: true) }

  it('belongs to criterion') { assoc(:criterion, :belongs_to) }

  it { is_expected.to be_valid }

  it '#eligible included in list' do
    subject.eligible = nil
    subject.valid?
    expect_error(:eligible, 'please select option')
  end

  it '#category can be Proposal' do
    expect(subject.category).to be_a(Proposal)
  end

  context do
    before { subject.category = build(:recipient) }

    it '#category can be Recipient' do
      expect(subject.category).to be_a(Recipient)
    end

    it 'category and criterion match' do
      subject.valid?
      expect_error(:eligible, 'Category must be Proposal')
    end
  end

  it 'unique to category and criterion' do
    subject.save!
    duplicate = subject.dup
    duplicate.valid?
    expect_error(:eligible, 'only one per fund', duplicate)
  end
end
