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
            expect(assessment.reasons).to include(
              avoid("Does not support work in the countries you're seeking")
            )
          end
        end

        context 'district mismatch' do
          let(:proposal_districts) { [build(:district)] }

          it { expect(eligibility).to eq(INELIGIBLE) }

          it 'avoid' do
            expect(assessment.reasons).to include(
              avoid("Does not support work in the areas you're seeking")
            )
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
              msgs = [
                'Some of your work takes place outside of the permitted areas',
                "Does not support work in the countries you're seeking"
              ]
              expect(assessment.reasons).to include(avoid(*msgs))
            end
          end

          context 'districts not contained' do
            let(:proposal_districts) { [@district, create(:district)] }
            it { expect(eligibility).to eq(INELIGIBLE) }

            it 'avoid' do
              msgs = [
                'Some of your work takes place outside of the permitted areas',
                "Does not support work in the areas you're seeking"
              ]
              expect(assessment.reasons).to include(avoid(*msgs))
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
            expect(assessment.reasons).to include(
              avoid("Does not support work in the countries you're seeking")
            )
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
              msgs = [
                'Some of your work takes place outside of the permitted areas',
                "Does not support work in the countries you're seeking"
              ]
              expect(assessment.reasons).to include(avoid(*msgs))
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
      expect(assessment.reasons).to include(
        avoid('Only supports local and regional work')
      )
    end
  end

  def approach
    { 'Check::Eligibility::Location' => { reasons: [], rating: 'approach' } }
  end

  def avoid(*msgs)
    {
      'Check::Eligibility::Location' => {
        reasons: [*msgs].to_set, rating: 'avoid'
      }
    }
  end
end
