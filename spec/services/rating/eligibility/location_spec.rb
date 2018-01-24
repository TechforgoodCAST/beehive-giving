require 'rails_helper'
require 'services/rating/shared'

describe Rating::Eligibility::Location do
  subject { Rating::Eligibility::Location.new(assessment: assessment) }
  let(:assessment) { nil }

  it('#title') { expect(subject.title).to eq('Location') }

  it_behaves_like 'incomplete'

  context 'ineligible' do
    let(:assessment) { build(:assessment, eligibility_location: INELIGIBLE) }

    it_behaves_like 'ineligible'

    it '#message' do
      area = assessment.fund.geo_area.name
      msg = "You are ineligible because of the #{area} of your proposal."
      expect(subject.message).to eq(msg)
    end
  end

  context 'eligible' do
    let(:assessment) { build(:assessment, eligibility_location: ELIGIBLE) }

    it_behaves_like 'eligible'

    it '#message' do
      area = assessment.fund.geo_area.name
      msg = "Awards funds in <strong>#{area}</strong>."
      expect(subject.message).to eq(msg)
    end
  end
end
