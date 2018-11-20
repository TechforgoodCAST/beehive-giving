require 'rails_helper'

describe Question do
  subject(:question) { build(:question, criterion: criterion, fund: fund) }

  let(:criterion) { create(:criterion) }
  let(:fund) { create(:fund) }

  it 'belongs to criterion' do
    assoc(:criterion, :belongs_to, polymorphic: true)
  end

  it 'belongs to fund' do
    assoc(:fund, :belongs_to, touch: true)
  end

  it 'has many answers' do
    assoc(:answers, :has_many, through: :criterion)
  end

  shared_examples 'raises RecordInvalid when has invalid values' do
    it do
      expect(subject).to be_invalid
      expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'when criterion is nil' do
    let(:criterion) { nil }
    it_behaves_like 'raises RecordInvalid when has invalid values'
  end
  context 'when fund is nil' do
    let(:fund) { nil }
    it_behaves_like 'raises RecordInvalid when has invalid values'
  end
end
