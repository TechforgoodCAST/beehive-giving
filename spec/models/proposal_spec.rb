require 'rails_helper'

describe Proposal do
  subject { build(:proposal) }

  it('belongs to Recipient') { assoc(:recipient, :belongs_to) }

  it('has many Answers') { assoc(:answers, :has_many, dependent: :destroy) }

  it('has many Assessments') { assoc(:assessments, :has_many) }

  it('has many Enquiries') { assoc(:enquiries, :has_many, dependent: :destroy) }

  it 'has many ProposalThemes' do
    assoc(:proposal_themes, :has_many, dependent: :destroy)
  end

  it('has many Themes') { assoc(:themes, :has_many, through: :proposal_themes) }

  it('HABTM AgeGroups') { assoc(:age_groups, :has_and_belongs_to_many) } # TODO: deprecated

  it('HABTM Beneficiaries') { assoc(:beneficiaries, :has_and_belongs_to_many) } # TODO: deprecated

  it('HABTM Countries') { assoc(:countries, :has_and_belongs_to_many) }

  it('HABTM Districts') { assoc(:districts, :has_and_belongs_to_many) }

  it('HABTM Implementations') { assoc(:implementations, :has_and_belongs_to_many) } # TODO: deprecated

  it { is_expected.to be_valid }

  it '#funding_duration must at least 1' do
    subject.funding_duration = 0
    subject.valid?
    expect_error(:funding_duration, 'must be greater than or equal to 1')
  end

  it '#funding_duration must be less than 120' do
    subject.funding_duration = 121
    subject.valid?
    expect_error(:funding_duration, 'must be less than or equal to 120')
  end

  context '#state' do
    it 'defaults to initial' do
      expect(subject.state).to eq('complete')
    end

    it 'transitions' do
      subject.save!
      {
        'basics'     => 'complete',
        'invalid'    => 'complete',
        'incomplete' => 'complete',
      }.each do |from, to|
        subject.state = from
        subject.complete!
        expect(subject.state).to eq(to)
      end
    end
  end

  it 'does not require districts if affect_geo at country level' do
    Proposal::AFFECT_GEO.each do |i|
      subject.affect_geo = i[1]
      subject.districts = []
      if i[1] < 2
        expect(subject).not_to be_valid
      else
        expect(subject).to be_valid
      end
    end
  end

  it '#clear_districts_if_country_wide' do
    expect(subject.district_ids.size).to eq(1)
    expect(subject.affect_geo).to eq(1)
    subject.affect_geo = 2
    subject.save
    expect(subject.district_ids.size).to eq(0)
  end

  context 'methods' do
    before do
      subject.eligibility = {
        'fund1' => { 'quiz' => { 'eligible' => false } },
        'fund2' => { 'quiz' => { 'eligible' => true }, 'other' => { 'eligible' => true } },
        'fund3' => { 'quiz' => { 'eligible' => true }, 'other' => { 'eligible' => false } },
        'fund4' => { 'other' => { 'eligible' => false } },
        'fund5' => { 'other' => { 'eligible' => true } }
      }
    end

    it '#eligible_funds' do # TODO: deprecated
      expect(subject.eligible_funds).to eq 'fund2' => { 'quiz' => { 'eligible' => true }, 'other' => { 'eligible' => true } }
    end

    it '#ineligible_funds' do # TODO: deprecated
      expect(subject.ineligible_funds).to eq 'fund1' => {"quiz"=>{"eligible"=>false}}, 'fund3' => {"quiz"=>{"eligible"=>true}, "other"=>{"eligible"=>false}}, 'fund4' => {"other"=>{"eligible"=>false}}
    end

    it '#eligible? unchecked' do # TODO: deprecated
      expect(subject.eligible?('fund4')).to eq nil
    end

    it '#eligible? eligible' do # TODO: deprecated
      expect(subject.eligible?('fund2')).to eq true
    end

    it '#eligible? ineligible' do # TODO: deprecated
      expect(subject.eligible?('fund1')).to eq false
      expect(subject.eligible?('fund3')).to eq false
    end

    it '#eligible_status unchecked' do # TODO: deprecated
      expect(subject.eligible_status('fund5')).to eq(-1)
    end

    it '#eligible_status eligible' do # TODO: deprecated
      expect(subject.eligible_status('fund2')).to eq 1
    end

    it '#eligible_status ineligible' do # TODO: deprecated
      expect(subject.eligible_status('fund1')).to eq 0
      expect(subject.eligible_status('fund3')).to eq 0
      expect(subject.eligible_status('fund4')).to eq 0
    end

    it '#eligibility_as_text check' do # TODO: deprecated
      expect(subject.eligibility_as_text('fund5')).to eq 'Check'
    end

    it '#eligibility_as_text eligible' do # TODO: deprecated
      expect(subject.eligibility_as_text('fund2')).to eq 'Eligible'
    end

    it '#eligibility_as_text ineligible' do # TODO: deprecated
      expect(subject.eligibility_as_text('fund1')).to eq 'Ineligible'
      expect(subject.eligibility_as_text('fund3')).to eq 'Ineligible'
      expect(subject.eligibility_as_text('fund4')).to eq 'Ineligible'
    end
  end
end
