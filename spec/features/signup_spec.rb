require 'rails_helper'
require_relative '../support/match_helper'
require_relative '../support/signup_helper'

feature 'Signup' do
  let(:user) { SignupHelper.new }
  let(:params) do
    { country: 'GB', funding_type: 1, org_type: 0, themes: ['', '1'] }
  end

  scenario 'invalid query string redirects to signup#basics' do
    visit signup_suitability_path(wrong: 'params')
    expect(current_path).to eq(root_path)
  end

  context do
    let(:opts) { {} }
    let(:with_fund) { false }

    before(:each) do
      MatchHelper.new.stub_charity_commission.stub_companies_house
      theme = create(:theme, id: 1, name: 'Theme1')
      @country = create(:country, districts: [create(:district)])
      if with_fund
        create(
          :fund_simple,
          themes: [theme],
          geo_area: build(:geo_area, countries: [@country])
        )
      end
      visit root_path
      user.complete_signup_basics_form(opts)
    end

    # TODO: js variant
    scenario 'can sign up' do
      expect(current_path).to eq(signup_suitability_path)

      user.complete_signup_suitability_form
      expect(current_path).to eq(funds_path(Proposal.last))
    end

    scenario 'query string persisted after multiple POST requests' do
      click_button 'Check suitability'
      expect(page).to have_current_path(signup_suitability_path(params))

      click_button 'Check suitability'
      expect(page).to have_current_path(signup_suitability_path(params))
    end

    scenario 'cannot visit signup#suitability when signed in' do
      user.complete_signup_suitability_form
      visit signup_suitability_path(params)
      expect(current_path).to eq(funds_path(Proposal.last))
    end

    scenario 'opting into funder verification sets Proposal#private false' do
      user.complete_signup_suitability_form
      expect(Proposal.last.private).to eq(false)
    end

    scenario 'opting out of funder verification sets Proposal#private true' do
      user.complete_signup_suitability_form(private: 'No')
      expect(Proposal.last.private).to eq(true)
    end

    scenario 'street address shown' do
      expect(page).to have_text('Street address')
    end

    context 'street address hidden' do
      let(:opts) do
        { org_type: 'A registered charity', charity_number: '1161998' }
      end
      scenario { expect(page).not_to have_text('Street address') }
    end

    scenario('fund count hidden') { expect(page).to have_text('Poor result?') }

    context 'fund count shown' do
      let(:with_fund) { true }
      let(:opts) do
        {
          org_type: 'A registered charity', charity_number: '1161998',
          country: @country.name
        }
      end
      scenario { expect(page).to have_text('1 grant fund found') }
    end

    scenario 'give marketing consent' do
      user.complete_signup_suitability_form
      expect(User.last.marketing_consent).to eq(true)
    end

    scenario 'deny marketing consent' do
      user.complete_signup_suitability_form(marketing_consent: 'No')
      expect(User.last.marketing_consent).to eq(false)
    end
  end

  scenario 'triggers assessments' do
    c = create(:country, districts: [create(:district)])
    create(:fund_simple, geo_area: create(:geo_area, countries: [c]))

    visit root_path
    user.complete_signup_basics_form
        .complete_signup_suitability_form

    expect(Assessment.count).to eq(1)
  end

  scenario 'individual sees notice with link', js: true do
    visit root_path
    select 'Myself OR another individual'
    expect(page).to have_text('IMPORTANT:')

    within '.individual_notice' do
      click_link 'FAQ'
    end
    expect(current_path).to eq faq_path
  end
end
