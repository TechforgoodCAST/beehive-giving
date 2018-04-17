require 'rails_helper'

feature 'Apply' do
  include ShowMeTheCookies

  let(:assessment) do
    create(
      assessment_state,
      fund: fund,
      proposal: proposal,
      recipient: recipient
    )
  end
  let(:assessment_state) { :assessment }
  let(:fund) { create(:fund_simple) }
  let(:proposal) { build(:proposal, recipient: recipient) }
  let(:recipient) do
    create(
      :recipient,
      reveals: reveals,
      subscription: Subscription.create(active: subscription_active)
    )
  end
  let(:reveals) { [] }
  let(:subscription_active) { false }
  let(:user) { create(:user, organisation: recipient) }

  before(:each) do
    create_cookie(:auth_token, user.auth_token)
    visit apply_path(fund, assessment.proposal)
  end

  context 'denies hidden fund' do
    it { expect(current_path).to eq(account_upgrade_path(recipient)) }
  end

  context 'denies ineligible' do
    let(:assessment_state) { :incomplete }
    it { expect(current_path).to eq(account_upgrade_path(recipient)) }
  end

  context 'denies ineligible' do
    let(:assessment_state) { :ineligible }
    it { expect(current_path).to eq(account_upgrade_path(recipient)) }
  end

  context 'denies eligible' do
    let(:assessment_state) { :eligible }
    it { expect(current_path).to eq(account_upgrade_path(recipient)) }
  end

  context 'grants eligible and subscribed' do
    let(:assessment_state) { :eligible }
    let(:subscription_active) { true }
    it { expect(current_path).to eq(apply_path(fund, proposal)) }
  end

  context 'grants eligible and revealed' do
    let(:assessment_state) { :eligible }
    let(:reveals) { [fund.slug] }

    it { expect(current_path).to eq(apply_path(fund, proposal)) }

    scenario 'tracks clicks' do
      click_link "Apply to #{fund.title}"
      expect(Enquiry.count).to eq(1)
      expect(Enquiry.last.approach_funder_count).to eq(1)
      expect(current_url).to eq(fund.application_link)

      visit apply_path(fund, assessment.proposal)
      click_link "Apply to #{fund.title}"
      expect(Enquiry.count).to eq(1)
      expect(Enquiry.last.approach_funder_count).to eq(2)
    end
  end
end
