require 'rails_helper'

describe Enquiry do
  subject { build(:enquiry) }

  it('belongs to Proposal') { assoc(:proposal, :belongs_to) }

  it('belongs to Fund') { assoc(:fund, :belongs_to) }

  it { is_expected.to be_valid }

  it 'approach_funder_count defaults to 0' do
    expect(subject.approach_funder_count).to eq 0
  end

  it 'is unique to proposal and fund' do
    duplicate = subject.dup
    expect(duplicate).not_to be_valid
  end
end
