require 'rails_helper'

describe Check::Eligibility::Location do
  let(:assessment) do
    build(
      :assessment,
      fund: build(
        :fund_with_rules,
        proposal_permitted_geographic_scales: permitted_geographic_scales,
        proposal_area_limited: proposal_area_limited,
        proposal_all_in_area: proposal_all_in_area,
        geo_area: create(
          :geo_area,
          children: false,
          countries: countries,
          districts: districts
        )
      ),
      proposal: build(
        :proposal,
        children: false,
        geographic_scale: geographic_scale,
        countries: proposal_countries,
        districts: proposal_districts
      )
    )
  end
  let(:geographic_scale) { 'local' }
  let(:permitted_geographic_scales) { %w[local regional] }
  let(:proposal_area_limited) { false }
  let(:proposal_all_in_area) { false }
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

  context 'scales match' do
    it { expect(eligibility).to eq(ELIGIBLE) }
    it { expect(assessment.reasons).to include(approach) }

    context 'area limited' do
      let(:proposal_area_limited) { true }

      context 'local or regional' do
        it('overlap') { expect(eligibility).to eq(ELIGIBLE) }
        it { expect(assessment.reasons).to include(approach) }

        context 'country mismatch' do
          let(:proposal_countries) { [build(:country)] }

          it { expect(eligibility).to eq(INELIGIBLE) }

          it 'avoid' do
            reason = {
              id: 'countries_ineligible',
              fund_value: assessment.fund.country_ids,
              proposal_value: assessment.proposal.country_ids
            }
            expect(assessment.reasons).to include(avoid(reason))
          end
        end

        context 'district mismatch' do
          let(:proposal_districts) { [build(:district)] }

          it { expect(eligibility).to eq(INELIGIBLE) }

          it 'avoid' do
            reason = {
              id: 'districts_ineligible',
              fund_value: assessment.fund.district_ids,
              proposal_value: assessment.proposal.district_ids
            }
            expect(assessment.reasons).to include(avoid(reason))
          end
        end

        context 'all in area' do
          let(:proposal_all_in_area) { true }
          it { expect(eligibility).to eq(ELIGIBLE) }
          it { expect(assessment.reasons).to include(approach) }

          context 'countries not contained' do
            let(:proposal_countries) { [@country, create(:country)] }

            it { expect(eligibility).to eq(INELIGIBLE) }

            it 'avoid' do
              reasons = [
                {
                  id: 'country_outside_area',
                  fund_value: assessment.fund.country_ids,
                  proposal_value: assessment.proposal.country_ids
                },
                {
                  id: 'countries_ineligible',
                  fund_value: assessment.fund.country_ids,
                  proposal_value: assessment.proposal.country_ids
                }
              ]
              expect(assessment.reasons).to include(avoid(*reasons))
            end
          end

          context 'districts not contained' do
            let(:proposal_districts) { [@district, create(:district)] }
            it { expect(eligibility).to eq(INELIGIBLE) }

            it 'avoid' do
              reasons = [
                {
                  id: 'district_outside_area',
                  fund_value: assessment.fund.district_ids,
                  proposal_value: assessment.proposal.district_ids
                },
                {
                  id: 'districts_ineligible',
                  fund_value: assessment.fund.district_ids,
                  proposal_value: assessment.proposal.district_ids
                }
              ]
              expect(assessment.reasons).to include(avoid(*reasons))
            end
          end
        end
      end

      context 'national or international' do
        let(:permitted_geographic_scales) { %w[national international] }
        let(:geographic_scale) { 'national' }
        let(:districts) { [] }

        it('overlap') { expect(eligibility).to eq(ELIGIBLE) }
        it { expect(assessment.reasons).to include(approach) }

        context 'country mismatch' do
          let(:proposal_countries) { [build(:country)] }

          it { expect(eligibility).to eq(INELIGIBLE) }

          it 'avoid' do
            reason = {
              id: 'countries_ineligible',
              fund_value: assessment.fund.country_ids,
              proposal_value: assessment.proposal.country_ids
            }
            expect(assessment.reasons).to include(avoid(reason))
          end
        end

        context 'all in area' do
          let(:proposal_all_in_area) { true }
          it { expect(eligibility).to eq(ELIGIBLE) }
          it { expect(assessment.reasons).to include(approach) }

          context 'countries not contained' do
            let(:proposal_countries) { [@country, create(:country)] }

            it { expect(eligibility).to eq(INELIGIBLE) }

            it 'avoid' do
              reasons = [
                {
                  id: 'country_outside_area',
                  fund_value: assessment.fund.country_ids,
                  proposal_value: assessment.proposal.country_ids
                },
                {
                  id: 'countries_ineligible',
                  fund_value: assessment.fund.country_ids,
                  proposal_value: assessment.proposal.country_ids
                }
              ]
              expect(assessment.reasons).to include(avoid(*reasons))
            end
          end
        end
      end
    end
  end

  context 'scales dont match' do
    let(:geographic_scale) { 'national' }

    it { expect(eligibility).to eq(INELIGIBLE) }

    it 'avoid' do
      reason = {
        id: 'geographic_scale_ineligible',
        fund_value: %w[local regional],
        proposal_value: 'national'
      }
      expect(assessment.reasons).to include(avoid(reason))
    end
  end

  def approach
    { 'Check::Eligibility::Location' => {
      rating: 'approach', reasons: [{ id: 'location_eligible'}]
    } }
  end

  def avoid(*msgs)
    {
      'Check::Eligibility::Location' => {
        reasons: [*msgs].to_set, rating: 'avoid'
      }
    }
  end
end
