require 'rails_helper'

describe Funder do
  subject { build(:funder, name: 'Funder Name') }

  it('has many Attempts') { assoc(:attempts, :has_many) }

  it('has many Funds') { assoc(:funds, :has_many) }

  it('has many Restrictions') { assoc(:restrictions, :has_many) }

  it('has many Users') { assoc(:users, :has_many, dependent: :destroy) }

  it { is_expected.to be_valid }

  it 'website invalid' do
    subject.website = 'www.example.com'
    expect(subject).not_to be_valid
  end

  it 'website valid' do
    subject.website = 'https://www.example.com'
    expect(subject).to be_valid
  end

  context 'slug' do
    before { subject.save }

    it 'present' do
      expect(subject.slug).to eq 'funder-name'
    end

    it 'unique' do
      expect(create(:funder, name: 'Funder Name').slug).to eq 'funder-name-2'
    end
  end
end
