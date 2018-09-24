require 'rails_helper'

describe Proposal do
  subject { build(:proposal) }

  it('belongs to Recipient') { assoc(:recipient, :belongs_to) }

  it('belongs to User') { assoc(:user, :belongs_to) }

  it('has many Assessments') { assoc(:assessments, :has_many) }

  it 'has many ProposalThemes' do
    assoc(:proposal_themes, :has_many, dependent: :destroy)
  end

  it('has many Themes') { assoc(:themes, :has_many, through: :proposal_themes) }

  it('HABTM Countries') { assoc(:countries, :has_and_belongs_to_many) }

  it('HABTM Districts') { assoc(:districts, :has_and_belongs_to_many) }

  it('has many Answers') { assoc(:answers, :has_many, dependent: :destroy) }

  it { is_expected.to be_valid }

  it 'required attributes' do
    %i[
      description
      category_code
      geographic_scale
      title
    ].each do |attribute|
      invalid_attribute(:proposal, attribute)
    end
  end

  it '#category_code in list' do
    subject.category_code = -1
    subject.valid?
    expect_error(:category_code, 'please select an option')
  end

  it '#geographic_scale in list' do
    subject.geographic_scale = -1
    subject.valid?
    expect_error(:geographic_scale, 'please select an option')
  end

  it 'has 1 or more themes' do
    subject.themes = []
    subject.valid?
    expect_error(:themes, 'please select 1 - 5 themes')
  end

  it 'has 5 themes or less' do
    subject.themes << build_list(:theme, 5)
    subject.valid?
    expect_error(:themes, 'please select 1 - 5 themes')
  end

  context 'other support' do
    before { subject.category_code = 101 }

    it '#support_details required' do
      subject.valid?
      expect_error(:support_details, "can't be blank")
    end
  end

  context 'seeking funding' do
    it 'required attributes' do
      %i[
        min_amount
        max_amount
        min_duration
        max_duration
      ].each do |attribute|
        invalid_attribute(:proposal, attribute)
      end
    end

    it '#max_amount greater than or equal to #min_amount' do
      subject.max_amount = subject.min_amount - 1
      subject.valid?
      expect_error(:max_amount, 'must be greater than or equal to 10000')
    end

    it '#max_duration greater than or equal to #min_duration' do
      subject.max_duration = subject.min_duration - 1
      subject.valid?
      expect_error(:max_duration, 'must be greater than or equal to 3')
    end

    it '#max_duration limited to 120' do
      subject.max_duration = 121
      subject.valid?
      expect_error(:max_duration, 'must be less than or equal to 120')
    end
  end

  context 'local' do
    it 'min one country' do
      subject.countries = []
      subject.valid?
      expect_error(:countries, 'please select a country')
    end

    it 'max one country' do
      subject.countries << build(:country)
      subject.valid?
      expect_error(:countries, 'please select a country')
    end

    it 'min one district' do
      subject.districts = []
      subject.valid?
      expect_error(:districts, 'please select districts')
    end
  end

  context 'national' do
    before do
      subject.geographic_scale = 'national'
    end

    it 'min one country' do
      subject.countries = []
      subject.valid?
      expect_error(:countries, 'please select a country')
    end

    it 'max one country' do
      subject.countries << build(:country)
      subject.valid?
      expect_error(:countries, 'please select a country')
    end

    it 'clears districts' do
      subject.valid?
      expect(subject.districts.size).to eq(0)
    end
  end

  context 'international' do
    before do
      subject.geographic_scale = 'international'
      subject.countries << build(:country)
    end

    it 'more than one country and no districts' do
      subject.districts = []
      expect(subject).to be_valid
    end

    it 'min one country' do
      subject.countries = []
      subject.valid?
      expect_error(:countries, 'please select countries')
    end

    it 'clears districts' do
      subject.valid?
      expect(subject.districts.size).to eq(0)
    end
  end

  it 'validates answers' do
    subject.answers.first.eligible = nil
    subject.valid?
    expect_error(:answers, 'is invalid')
  end

  it 'validates user' do
    subject.user.email = nil
    subject.valid?
    expect_error(:user, 'is invalid')
  end

  it '#access_token set before create' do
    subject.save
    expect(subject.access_token).not_to eq(nil)
    expect(subject.access_token.size).to eq(22)
  end

  it '#category_name' do
    expect(subject.category_name).to eq('Revenue - Core')
  end

  scenario '#country set'

  scenario 'countries & districts properly cleared & last selection takes precedence'

  scenario 'districts only for country allowed'
end
