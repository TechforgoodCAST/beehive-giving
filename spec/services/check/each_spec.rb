require 'rails_helper'

describe Check::Each do
  let(:criteria) { [Check::Eligibility::OrgType.new] }
  let(:funds)    { Fund.active }
  let(:themes)   { build_list(:theme, 1) }
  let(:proposal) do
    build(
      :proposal,
      state: 'initial',
      themes: themes,
      age_groups: create_list(:age_group, 1),
      countries: build_list(:country, 1),
      districts: build_list(:district, 1)
    )
  end
  let(:assessment) do
    create(
      :assessment,
      recipient: proposal.recipient,
      proposal: proposal,
      fund: create_list(
        :fund, 2,
        themes: themes,
        restrictions_known: false,
        priorities_known: false
      )[0]
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

  it 'only returns changed Assessments' do
    assessment.update(eligibility_org_type: 1)
    expect(subject.size).to eq(1)
  end
end
