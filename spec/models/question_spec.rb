require 'rails_helper'

describe Question do
  subject(:question) { build(:question, criterion: criterion, fund: fund, group: group) }
  let(:criterion) { create(:criterion) }
  let(:fund) { create(:fund) }
  let(:group) { nil }

  it 'belongs to criterion' do
    assoc(:criterion, :belongs_to, polymorphic: true)
  end

  it 'belongs to fund' do
    assoc(:fund, :belongs_to, touch: true)
  end

  it 'has_many answers' do
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
  context ' when fund is nil' do
    let(:fund) { nil }
    it_behaves_like 'raises RecordInvalid when has invalid values'
  end

  context 'grouped scope' do
    subject { described_class.grouped(*scope_params) }
    before { question.save }

    let(:group) { 'test_group' }
    let(:scope_params) { [nil, nil] }
    context 'when matches' do
      let(:scope_params) { [question.criterion_type, group] }
      it { expect(subject.size).to eq(1) }
    end
    context 'when does not match' do
      it { expect(subject.size).to eq(0) }
    end
  end
end
