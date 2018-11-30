require 'rails_helper'

describe Funder do
  subject { build(:funder, name: 'Funder Name') }

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

  context '#active_opportunities_count' do
    it 'updated when active opportunity added' do
      expect(subject.active_opportunities_count).to eq(0)
      expect_opportunity_added
    end

    it 'updated when opportunity no longer active' do
      expect_opportunity_added
      @opportunity.update!(state: 'inactive')
      expect(subject.active_opportunities_count).to eq(0)
    end

    it 'updated when opportunity destroyed' do
      expect_opportunity_added
      @opportunity.destroy
      expect(subject.active_opportunities_count).to eq(0)
    end
  end

  def expect_opportunity_added
    @opportunity = build(:fund, state: 'active')
    subject.update!(funds: [@opportunity])
    expect(subject.active_opportunities_count).to eq(1)
  end
end
