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

  it('HABTM AgeGroups') { assoc(:age_groups, :has_and_belongs_to_many) }

  it('HABTM Beneficiaries') { assoc(:beneficiaries, :has_and_belongs_to_many) } # TODO: deprecated

  it('HABTM Countries') { assoc(:countries, :has_and_belongs_to_many) }

  it('HABTM Districts') { assoc(:districts, :has_and_belongs_to_many) }

  it('HABTM Implementations') { assoc(:implementations, :has_and_belongs_to_many) } # TODO: deprecated

  it { is_expected.to be_valid }

  context '#state' do
    it 'defaults to initial' do
      expect(subject.state).to eq('initial')
    end

    it 'transitions' do
      subject.save!
      {
        'basics'      => 'initial',
        'initial'     => 'registered',
        'transferred' => 'registered',
        'registered'  => 'complete',
        'complete'    => 'complete'
      }.each do |from, to|
        subject.state = from
        subject.next_step!
        expect(subject.state).to eq(to)
      end
    end
  end

  it 'clears age_groups and gender unless affect_people' do
    expect(subject.age_groups.size).to eq(1)
    expect(subject.gender).to eq('Female')

    subject.affect_people = false
    subject.save!

    expect(subject.age_groups.size).to eq 0
    expect(subject.gender).to eq nil
  end

  it 'requires gender if affect_people' do
    subject.gender = nil
    expect(subject).to_not be_valid
  end

  it 'requires age_groups if affect_people' do
    subject.age_groups = []
    expect(subject).to_not be_valid
  end

  it 'does not require gender and age_groups if affect_other' do
    subject.affect_people = false
    subject.affect_other = true
    subject.gender = nil
    subject.age_groups = []
    expect(subject).to be_valid
  end

  it 'selects all age groups if first AgeGroup selected' do
    expect(subject.age_groups.first.label).to eq('All ages')
    expect(subject.age_groups.size).to eq(1)
    subject.save!
    expect(subject.age_groups.size).to eq(8)
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

  context 'registered' do
    subject { build(:registered_proposal) }

    it { is_expected.to be_valid }

    it('#state') { expect(subject.state).to eq('registered') }

    it 'cannot create second proposal until first proposal complete' do
      subject.save!
      proposal = build(:proposal, recipient: subject.recipient)
      expect(proposal).not_to be_valid

      error = proposal.errors.messages[:proposal][0]
      msg = 'Please complete your first proposal before creating a second.'
      expect(error).to eq(msg)
    end
  end

  context 'complete' do
    subject { build(:complete_proposal) }

    it { is_expected.to be_valid }

    it('#state') { expect(subject.state).to eq('complete') }

    context 'multiple' do
      let(:duplicate) do
        build(
          :registered_proposal,
          recipient: subject.recipient,
          title: subject.title
        )
      end

      before do
        subject.save!
        expect(duplicate).not_to be_valid
      end

      it 'title unique to recipient' do
        error = duplicate.errors.messages[:title][0]
        msg = 'each proposal must have a unique title'
        expect(error).to eq(msg)
      end

      # TODO: deprecated
      it 'subscription required to create multiple proposals' do
        error = duplicate.errors.messages[:title][1]
        msg = 'Upgrade subscription to create multiple proposals'
        expect(error).to eq(msg)
      end

      # TODO: deprecated
      it 'can create multiple proposals once first proposal complete ' \
         'and subscribed' do
        subject.recipient.create_subscription!
        subject.recipient.subscription.update(active: true)
        duplicate.title = 'unique'
        expect(duplicate).to be_valid
      end
    end
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
