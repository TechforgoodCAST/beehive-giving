require 'rails_helper'

describe Check::Each do
  let(:criteria) { [Check::Eligibility::Amount] }
  let(:funds)    { Fund.active }
  let(:assessment) do
    create(
      :assessment,
      fund: create_list(:fund_with_rules, 2, state: 'active')[0],
      fund_version: Fund.version
    )
  end

  before { assessment }

  subject { Check::Each.new(criteria).call_each(funds, assessment.proposal) }

  context 'missing criteria' do
    let(:criteria) { nil }
    it('raise error') { expect { subject }.to raise_error(ArgumentError) }
  end

  context 'empty criteria' do
    let(:criteria) { [] }
    it('returns persisted Assessments') { expect(subject.size).to eq(1) }
  end

  it 'returns Array of one valid Assessment per Fund' do
    expect(subject).to be_an(Array)
    expect(subject.size).to eq(2)
    subject.each do |assessment|
      expect(assessment).to be_an(Assessment)
      expect(assessment).to be_valid
    end
  end

  it 'initializes new Assessments for new Funds' do
    expect(Assessment.count).to eq(1)
    expect(subject.size).to eq(2)
  end

  it 'returns changed Assessments only' do
    subject[0].save
    check = Check::Each.new(criteria).call_each(funds, assessment.proposal)
    expect(check.size).to eq(1)
  end
end
