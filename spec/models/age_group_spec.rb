require 'rails_helper'

describe AgeGroup do
  subject { AgeGroup.first }

  # TODO: refactor
  before(:all) do
    create_list(:age_group, AgeGroup::AGE_GROUPS.count) unless AgeGroup.any?
  end

  it('HABTM AgeGroups') { assoc(:proposals, :has_and_belongs_to_many) }

  it { is_expected.to be_valid }

  it 'ensure values in AGE_GROUPS' do
    %i[label age_from age_to].each do |f|
      subject[f] = '-1'
      expect(subject).not_to be_valid
      expect(subject.errors[f]).to include(":#{f} '-1' not in AGE_GROUPS")
    end
  end
end
