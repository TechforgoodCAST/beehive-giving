require 'rails_helper'
require 'services/rating/shared'

describe Rating::Eligibility::Quiz do
  subject { Rating::Eligibility::Quiz.new(assessment: assessment) }
  let(:assessment) { nil }

  it('#title') { expect(subject.title).to eq('Quiz') }

  context 'incomplete' do
    it('#colour') { expect(subject.colour).to eq('blue') }
    it('#message') { expect(subject.message).to eq('-') }
    it('#status') { expect(subject.status).to eq('Incomplete') }
  end

  context 'ineligible' do
    let(:assessment) do
      build(:assessment, eligibility_quiz: 0, eligibility_quiz_failing: 1)
    end

    it_behaves_like 'ineligible'

    it '#message' do
      msg = 'You are ineligible, and do not meet <strong>1</strong> of ' \
            'the criteria below.'
      expect(subject.message).to eq(msg)
    end
  end

  context 'eligible' do
    let(:assessment) { build(:assessment, eligibility_quiz: 1) }

    it_behaves_like 'eligible'

    it('#message') { expect(subject.message).to eq('-') }
  end
end
