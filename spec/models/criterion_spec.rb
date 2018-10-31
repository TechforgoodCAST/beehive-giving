require 'rails_helper'

describe 'Criterion' do
  subject { build(:criterion) }

  it('has many Answers') { assoc(:answers, :has_many) }

  it('has many Funds') { assoc(:funds, :has_many, through: :questions) }

  it('has many Questions') { assoc(:questions, :has_many) }

  it { is_expected.to be_valid }

  context '#category' do
    it 'default' do
      expect(subject.category).to eq('Proposal')
    end

    it 'in range' do
      subject.update(category: nil)
      expect_error(:category, 'is not included in the list')
    end
  end

  context '#details' do
    it 'presence' do
      subject.update(details: nil)
      expect_error(:details, "can't be blank")
    end

    it 'uniqueness' do
      subject.save!
      clone = subject.dup
      clone.valid?
      expect_error(:details, 'has already been taken', clone)
    end
  end

  it '#invert defaults to false' do
    expect(subject.invert).to eq(false)
  end

  context '#radio_button_values' do
    it 'default' do
      expect(subject.radio_button_values).to eq([['Yes', false], ['No', true]])
    end

    it 'inverted' do
      subject.invert = true
      expect(subject.radio_button_values).to eq([['Yes', true], ['No', false]])
    end
  end
end
