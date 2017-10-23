require 'rails_helper'
require 'validations/reg_no_validations_shared_examples'

describe EligibilityStep do
  include_examples 'reg no validations'

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
