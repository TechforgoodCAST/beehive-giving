require 'rails_helper'

describe Rating::Each do
  let(:assessment) { build(:assessment, reasons: reasons) }
  let(:reasons) { {} }

  subject { Rating::Each.new(assessment) }

  context '#rating' do
    it('no reasons') { expect(subject.ratings).to eq([]) }

    context 'has reasons' do
      let(:reasons) do
        { 'Check::Eligibility::Amount' => { reasons: [], rating: 'approach' } }
      end

      it { expect(subject.ratings.first).to be_a(Rating::Eligibility::Amount) }
    end
  end
end
