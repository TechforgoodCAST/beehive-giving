require 'rails_helper'

describe Check::Eligibility::Location do
  let(:assessment) do
    build(
      :assessment,
      fund: build(
        :fund,
        geographic_scale_limited: geographic_scale_limited,
        national: national,
        geo_area: create(
          :geo_area,
          countries: countries,
          districts: districts
        )
      ),
      proposal: build(
        :proposal,
        affect_geo: affect_geo,
        countries: proposal_countries,
        districts: proposal_districts
      )
    )
  end
  let(:geographic_scale_limited) { false }
  let(:national) { false }
  let(:affect_geo) { 2 }
  let(:countries) { [@country] }
  let(:districts) { [@district] }
  let(:proposal_countries) { countries }
  let(:proposal_districts) { districts }
  let(:eligibility) { assessment.eligibility_location }

  before do
    @district = create(:district)
    @country = @district.country
    subject.call(assessment)
  end

  context 'a Proposal from an unsupported country' do
    let(:affect_geo) { 2 }
    let(:proposal_countries) { [] }
    it('is ineligible') { expect(eligibility).to eq(INELIGIBLE) }
  end

  context 'a local Proposal' do
    let(:affect_geo) { 0 }

    context 'to a local Fund' do
      let(:geographic_scale_limited) { true }
      it('is eligible') { expect(eligibility).to eq(ELIGIBLE) }

      context 'in a different area' do
        let(:proposal_districts) { [] }
        it('is ineligible') { expect(eligibility).to eq(INELIGIBLE) }
      end

      context 'sharing some areas in common' do
        let(:proposal_districts) { districts << create(:district) }
        it('is eligible') { expect(eligibility).to eq(ELIGIBLE) }
      end
    end

    context 'to a national Fund' do
      let(:geographic_scale_limited) { true }
      let(:national) { true }
      it('is ineligible') { expect(eligibility).to eq(INELIGIBLE) }
    end

    context 'to an anywhere Fund' do
      it('is eligible') { expect(eligibility).to eq(ELIGIBLE) }
    end
  end

  context 'a national Proposal' do
    context 'to a local Fund' do
      let(:geographic_scale_limited) { true }
      it('is eligible') { expect(eligibility).to eq(ELIGIBLE) }
    end

    context 'to a national Fund' do
      let(:geographic_scale_limited) { true }
      let(:national) { true }
      it('is eligible') { expect(eligibility).to eq(ELIGIBLE) }
    end

    context 'to an anywhere Fund' do
      it('is eligible') { expect(eligibility).to eq(ELIGIBLE) }
    end
  end
end
