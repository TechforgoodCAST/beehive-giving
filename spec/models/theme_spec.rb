require 'rails_helper'

describe Theme do
  subject { build(:theme) }

  it('belongs to parent Theme') { assoc(:parent, :belongs_to) }

  it('has many to parent Themes') { assoc(:themes, :has_many) }

  it 'has many FundThemes' do
    assoc(:fund_themes, :has_many, dependent: :destroy)
  end

  it('has many Funds') { assoc(:funds, :has_many, through: :fund_themes) }

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

  it '#related must be Hash' do
    subject.related = 'string'
    expect(subject).not_to be_valid
  end

  it '#related must have valid keys' do
    subject.related = { 'missing' => 1 }
    expect(subject).not_to be_valid
  end

  it '#related value must be Float or Integer' do
    subject.save!
    ['', [], {}].each do |val|
      subject.related = { subject.name => val }
      expect(subject).not_to be_valid
    end

    [1, 1.0].each do |val|
      subject.related = { subject.name => val }
      subject.reload
      expect(subject).to be_valid
    end
  end

  it('#primary_color') { expect(subject.primary_color).to eq(nil) }
  it('#secondary_color') { expect(subject.primary_color).to eq(nil) }
end
