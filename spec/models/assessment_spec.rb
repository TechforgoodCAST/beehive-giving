require 'rails_helper'

describe Assessment do
  subject { build(:assessment) }

  it('belongs to Fund') { assoc(:fund, :belongs_to) }

  it('belongs to Proposal') { assoc(:proposal, :belongs_to) }

  it('belongs to Recipient') { assoc(:recipient, :belongs_to) }

  it { is_expected.to be_valid }

  it 'requires associations' do
    %i[fund proposal recipient].each do |assoc|
      subject.send("#{assoc}=", nil)
      is_expected.not_to be_valid
    end
  end

  context do
    let(:proposal) { create(:proposal) }

    before do
      create(
        :fund,
        restrictions_known: false,
        priorities_known: false,
        themes: [build(:theme)],
        geo_area: create(:geo_area, countries: proposal.countries)
      )
    end

    it 'self.analyse' do
      assessment = Assessment.analyse(Fund.active, proposal)[0]
      expect(Assessment.count).to eq(0)

      %i[
        eligibility_amount
        eligibility_location
        eligibility_org_income
        eligibility_org_type
        eligibility_quiz
      ].each do |column|
        expect(assessment.send(column)).to eq(ELIGIBLE)
      end
      expect(assessment.eligibility_quiz_failing).to eq(0)
      expect(assessment.eligibility_funding_type).to eq(nil)
    end

    it 'self.analyse_and_update!' do
      Assessment.analyse_and_update!(Fund.active, proposal)
      expect(Assessment.count).to eq(1)
    end

    it 'self.analyse_and_update! duplicate keys'
  end

  it '#eligibility_status unset before_validation' do
    assessment = Assessment.new
    expect(assessment.eligibility_status).to eq(nil)
  end

  context '#eligibility_status' do
    context 'incomplete' do
      it { expect(subject.eligibility_status).to eq(INCOMPLETE) }
    end

    context 'ineligible' do
      subject { build(:ineligible) }
      it { expect(subject.eligibility_status).to eq(INELIGIBLE) }
    end

    context 'eligible' do
      subject { build(:eligible) }
      it { expect(subject.eligibility_status).to eq(ELIGIBLE) }
    end
    end

  it '#attributes keys symbolized' do
    subject.attributes.keys.each { |k| expect(k).to be_a(Symbol) }
  end
end
