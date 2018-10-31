require 'rails_helper'

describe Recipient do
  subject { build(:recipient) }

  it('belongs to Country') { assoc(:country, :belongs_to) }

  it('belongs to District') { assoc(:district, :belongs_to) }

  it('belongs to User') { assoc(:user, :belongs_to, optional: true) }

  it('has one Proposals') { assoc(:proposal, :has_one) }

  it('has many Answers') { assoc(:answers, :has_many, dependent: :destroy) }

  it('has many Assessments') { assoc(:assessments, :has_many) }

  context 'individual' do
    subject { build(:individual) }

    it { is_expected.to be_valid }

    it 'required attributes' do
      %i[
        category_code
        country
        district
      ].each do |attribute|
        invalid_attribute(:recipient, attribute)
      end
    end
  end

  context 'unincorporated organisation' do
    it 'description not required' do
      subject.category_code = 201
      subject.description = nil
      expect(subject).to be_valid
    end
  end

  context 'organisation' do
    it { is_expected.to be_valid }

    it 'required attributes' do
      %i[
        category_code
        country
        district
        description
        income_band
        name
        operating_for
      ].each do |attribute|
        invalid_attribute(:recipient, attribute)
      end
    end

    it 'in list' do
      %i[
        operating_for
        income_band
      ].each do |attribute|
        invalid_attribute(:recipient, attribute, -100)
      end
    end
  end

  it '#category_code in list' do
    subject.category_code = -1
    subject.valid?
    expect_error(:category_code, 'please select an option')
  end

  it '#category_name' do
    expect(subject.category_name).to eq('A charitable organisation')
  end

  context '#income_band_name' do
    it 'found' do
      expect(subject.income_band_name).to eq('Less than £10k')
    end

    it 'not found' do
      subject.income_band = nil
      expect(subject.income_band_name).to eq(nil)
    end
  end

  context '#individual?' do
    it 'false' do
      expect(subject.individual?).to eq(false)
    end

    it 'true' do
      subject.category_code = 101
      expect(subject.individual?).to eq(true)
    end
  end

  it 'invalid #website' do
    subject.website = 'www.example.com'
    expect(subject).not_to be_valid
  end

  context '#operating_for_name' do
    it 'found' do
      expect(subject.operating_for_name).to eq('Yet to start')
    end

    it 'not found' do
      subject.operating_for = nil
      expect(subject.operating_for_name).to eq(nil)
    end
  end

  it 'strips whitespace' do
    %i[
      charity_number
      company_number
    ].each do |attribute|
      subject.send("#{attribute}=", ' with whitespace ')
      expect(subject[attribute]).to eq('with whitespace')
    end
  end

  it 'validates answers' do
    subject.answers << build(:answer)
    subject.valid?
    expect_error(:answers, 'is invalid')
  end
end
