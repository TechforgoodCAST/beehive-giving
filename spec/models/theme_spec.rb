require 'rails_helper'

describe Theme do
  subject { build(:theme) }

  it('belongs to parent Theme') { assoc(:parent, :belongs_to) }

  it('has many to parent Themes') { assoc(:themes, :has_many) }

  it('has many Criteria') { assoc(:criteria, :has_many, through: :funds) }

  it 'has many FundThemes' do
    assoc(:fund_themes, :has_many, dependent: :destroy)
  end

  it('has many Funds') { assoc(:funds, :has_many, through: :fund_themes) }

  it('has many Priorities') { assoc(:priorities, :has_many, through: :funds) }

  it('has many Proposals') { assoc(:proposals, :has_many, as: :collection) }

  it 'has many Assessments' do
    assoc(:assessments, :has_many, through: :proposals)
  end

  it 'has many Restrictions' do
    assoc(:restrictions, :has_many, through: :funds)
  end

  it { is_expected.to be_valid }

  it 'parent is Theme' do
    subject.parent = build(:theme)
    is_expected.to be_valid
  end

  it 'self.primary' do
    subject.save!
    expect(Theme.primary.size).to eq(1)
  end

  it '#name is unique' do
    subject.save!
    expect(build(:theme, name: subject.name)).not_to be_valid
  end

  it '#slug based on #name' do
    subject.name = 'New Name'
    subject.save!
    expect(subject.slug).to eq('new-name')
  end

  it('#primary_color') { expect(subject.primary_color).to eq(nil) }

  it('#secondary_color') { expect(subject.primary_color).to eq(nil) }

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
    @opportunity = create(:fund, state: 'active', themes: [subject])
    expect(subject.active_opportunities_count).to eq(1)
  end
end
