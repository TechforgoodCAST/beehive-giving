require 'rails_helper'

describe EligibilityStep do
  it 'Recipient validations from shared module' do
    raise
  end

  it '#answers=' do
    answer_params = {
      category_id: 2,
      category_type: 'Recipient',
      criterion_id: 1
    }
    subject.answers = { '1': answer_params.merge(eligible: '') }

    expect(subject.answers.first)
      .to have_attributes(answer_params.merge(eligible: nil))
  end

  context 'with Funder' do
    let(:funder) do
      instance_double(Funder, restrictions: create_list(:restriction, 2))
    end

    it '#build_answers' do
      answers = subject.build_answers(funder, build(:proposal))
      expect(answers.size).to eq 2
      expect(answers.first.criterion_id).to eq 1
    end
  end

  it '#answers_for with no #answers' do
    expect(subject.answers_for('Proposal')).to eq []
  end

  it '#answers_for invalid `category`' do
    expect(subject.answers_for('Prop')).to eq []
  end

  it '#answers_for' do
    subject.answers = { '1': { category_type: 'Proposal' } }
    expect(subject.answers_for('Proposal').size).to eq 1
  end

  context '#save' do
    it 'updates Recipient' do
      raise
    end

    it 'updates runs eligibility check and updates Proposal' do
      raise
    end

    it 'updates Assessment' do
      raise
    end
  end
end
