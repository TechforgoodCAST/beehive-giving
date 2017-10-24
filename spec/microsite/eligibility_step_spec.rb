require 'rails_helper'
require 'shared/recipient_validations'
require 'shared/reg_no_validations'
require 'shared/org_type_validations'

describe EligibilityStep do
  include_examples 'recipient validations'
  include_examples 'reg no validations'
  include_examples 'org_type validations'

  let(:attrs) do
    %i[
      assessment org_type charity_number company_number name country
      street_address income_band operating_for employees volunteers
    ]
  end

  it 'self.attrs' do
    expect(subject.class.attrs).to include(*attrs)
  end

  it '#attributes' do
    expect(subject.attributes).to include(*attrs)
    expect(subject.attributes).to be_a(Hash)
  end

  it '#answers empty' do
    expect(subject.answers).to eq []
  end

  context 'with answers params' do
    let(:answer_params) do
      { category_id: 2, category_type: 'Recipient', criterion_id: 1 }
    end

    before(:each) do
      subject.answers = { '1': answer_params.merge(eligible: '') }
    end

    it '#answers' do
      expect(subject.answers.size).to eq 1
    end

    it '#answers=' do
      expect(subject.answers.first)
        .to have_attributes(answer_params.merge(eligible: nil))
    end
  end

  context 'with Funder' do
    let(:funder) do
      instance_double(Funder, restrictions: build_list(:restriction, 2))
    end

    it '#build_answers' do
      answers = subject.build_answers(funder, build(:proposal))
      expect(answers.size).to eq 2
    end
  end

  it '#answers_for invalid `category`' do
    expect(subject.answers_for('Prop')).to eq []
  end

  it '#answers_for' do
    subject.answers = { '1': { category_type: 'Proposal' } }
    expect(subject.answers_for('Proposal').size).to eq 1
  end

  context '#save' do
    let(:recipient) { build(:recipient) }
    let(:assessment) { Assessment.new(recipient: recipient) }

    it 'updates Recipient' do
      subject.assign_attributes(
        assessment: assessment,
        org_type: 1,
        charity_number: '123',
        name: 'charity name',
        country: 'GB',
        operating_for: 0, # Yet to start
        income_band: 0, # Less than 10k
        employees: 0, # None
        volunteers: 0 # None
      )
      subject.save
      expect(recipient.name).to eq 'Charity name'
    end

    it 'updates runs eligibility check and updates Proposal' do
      result = {}
      expect(subject.proposal.eligibility).not_to eq result
    end

    it 'updates Assessment' do
      expect(subject.assessment.state).to eq 'results'
    end
  end
end
