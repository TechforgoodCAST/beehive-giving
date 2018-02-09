require 'rails_helper'
require 'shared/recipient_validations'
require 'shared/reg_no_validations'
require 'shared/org_type_validations'
require 'shared/setter_to_integer'

describe EligibilityStep do
  include_examples 'recipient validations'
  include_examples 'reg no validations'
  include_examples 'org_type validations'
  include_examples 'setter to integer' do
    let(:attributes) do
      %i[org_type income_band operating_for employees volunteers affect_geo]
    end
  end

  let(:attrs) do
    %i[
      attempt org_type charity_number company_number name country
      street_address income_band operating_for employees volunteers
      affect_geo country_ids district_ids
    ]
  end

  it 'self.attrs' do
    expect(subject.class.attrs).to include(*attrs)
  end

  it '#answers empty' do
    expect(subject.answers).to eq []
  end

  it '#country_ids default' do
    expect(subject.country_ids).to eq []
  end

  it '#district_ids default' do
    expect(subject.district_ids).to eq []
  end

  it '#country_ids_presence valid' do
    [0, 1, 2].each do |affect_geo|
      subject.affect_geo = affect_geo
      subject.valid?
      expect(subject.errors.messages).not_to have_key :country_ids
    end
  end

  it '#country_ids_presence invalid' do
    subject.affect_geo = 3
    subject.valid?
    expect(subject.errors.messages).to have_key :country_ids
  end

  it '#district_ids_presence valid' do
    [0, 1].each do |affect_geo|
      subject.affect_geo = affect_geo
      subject.valid?
      expect(subject.errors.messages).to have_key :district_ids
    end
  end

  it '#district_ids_presence invalid' do
    [2, 3].each do |affect_geo|
      subject.affect_geo = affect_geo
      subject.valid?
      expect(subject.errors.messages).not_to have_key :district_ids
    end
  end

  it '#attributes' do
    expect(subject.attributes).to include(*attrs)
    expect(subject.attributes).to be_a(Hash)
  end

  it '#answers_for invalid `category`' do
    expect(subject.answers_for('Prop')).to eq []
  end

  context 'with Attempt' do
    let(:restriction) { build(:restriction, id: 1) }
    let(:attempt) do
      instance_double(
        Attempt,
        recipient: build(:recipient),
        proposal: build(:proposal, id: 1),
        funder: instance_double(Funder, restrictions: [restriction])
      )
    end
    let(:answers) { { restriction.id.to_s => { 'eligible' => true } } }

    before do
      subject.assign_attributes(
        attempt: attempt,
        org_type: 1,
        charity_number: '123',
        name: 'charity name',
        country: 'GB',
        operating_for: 0, # Yet to start
        income_band: 0, # Less than 10k
        employees: 0, # None
        volunteers: 0, # None
        affect_geo: 2, # An entire country
        answers: answers
      )
    end

    it '#answers' do
      expect(subject.answers.size).to eq 1
    end

    it '#answers=' do
      subject.answers = { restriction.id.to_s => { 'eligible' => false } }
      expect(subject.answers.first).to have_attributes(eligible: false)
    end

    it '#answers_for' do
      expect(subject.answers_for('Proposal').size).to eq 1
    end

    context '#save' do
      let(:attempt) do
        @app.seed_test_db
            .create_recipient
            .create_registered_proposal
            .setup_funds

        Attempt.create!(
          recipient: Recipient.last,
          proposal: Proposal.last,
          funder: Funder.last
        )
      end

      let(:answers) do
        Funder.last.restrictions.map do |r|
          [r.id.to_s, { 'eligible' => true }]
        end.to_h
      end

      it 'valid answers saved' do
        subject.valid?
        expect(Answer.count).to eq 5
      end

      it 'displays existing answer.eligible' do
        subject.valid?
        expect(subject.answers.first).to have_attributes(eligible: true)
      end

      it 'does not create duplicate answers' do
        subject.valid?
        expect(Answer.count).to eq 5

        subject.answers = answers.each { |_, v| v['eligible'] = false }
        expect(subject.answers.first).to have_attributes(eligible: false)
        expect(Answer.count).to eq 5
      end

      it 'updates Recipient' do
        subject.save
        expect(Recipient.last.name).to eq 'Charity name'
      end

      it 'updates runs eligibility check' do
        subject.save
        expect(subject.attempt.proposal.assessments.size).to eq(1)
      end

      it '#save updates Attempt' do
        subject.save
        expect(subject.attempt.state).to eq 'pre_results'
      end
    end
  end
end