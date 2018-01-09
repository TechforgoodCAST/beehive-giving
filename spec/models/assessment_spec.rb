require 'rails_helper'

describe Assessment do
  subject { build(:assessment) }

  it('belongs to Fund') { assoc(:fund, :belongs_to) }

  it('belongs to Proposal') { assoc(:proposal, :belongs_to) }

  it('belongs to Recipient') { assoc(:recipient, :belongs_to) }

  it { is_expected.to be_valid }

  it 'requires associations' do
    %i[fund proposal recipient].each do |assoc|
      subject.send("#{assoc}=", nil)
      is_expected.not_to be_valid
    end
  end
end
