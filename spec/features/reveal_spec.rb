require 'rails_helper'
require_relative '../support/eligibility_helper'

feature 'RevealFunds' do
  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 7, open_data: true)
        .create_recipient
        .with_user
        .create_complete_proposal
        .sign_in
    @user = User.last
    @recipient = Recipient.last
    @proposal = Proposal.last
    @fund = Fund.last
  end

  context 'v2 subscription' do
    before(:each) do
      Subscription.last.update(version: 2)
      visit proposal_fund_path(@proposal, @fund)
    end

    scenario 'reveal button hidden once revealed' do
      click_link('Reveal')
      expect(page).not_to have_link('Reveal')
      expect(@user.reveals.size).to eq(1)
    end

    scenario 'Featured fund does not need to be revealed' do
      @fund.update(featured: true)
      visit proposal_fund_path(@proposal, @fund)
      expect(page).not_to have_link('Reveal')
    end

    context 'limit reached' do
      before(:each) do
        @recipient.update(reveals: [1, 2, 3])
        visit proposal_fund_path(@proposal, @fund)
      end

      scenario 'cant reveal fund after reaching limit' do
        click_link('Reveal')
        expect(current_path).to eq(account_upgrade_path(@recipient))
      end

      scenario 'can browse redacted fund after reaching limit' do
        visit proposal_funds_path(@proposal)
        click_link('Hidden fund', match: :first)
        expect(current_path).to eq(hidden_proposal_fund_path(@proposal, @fund))
      end

      scenario 'can check eligibility after reaching limit' do
        helper = EligibilityHelper.new
        helper.answer_restrictions(@fund).answer_priorities(@fund)
        click_button 'Check eligibility'
        assessment = @proposal.assessments.where(fund: @fund).last
        expect(assessment.eligibility_quiz).to eq(1)
      end

      scenario 'can apply once revealed' do
        create(:eligible, fund: @fund, proposal: @proposal)

        visit apply_proposal_fund_path(@proposal, @fund)
        expect(current_path).to eq(account_upgrade_path(@recipient))

        @recipient.update(reveals: [@fund.slug])
        visit apply_proposal_fund_path(@proposal, @fund)
        expect(current_path).to eq(apply_proposal_fund_path(@proposal, @fund))
      end

      scenario 'can apply once subscribed' do
        create(:eligible, fund: @fund, proposal: @proposal)
        @recipient.subscribe!
        visit apply_proposal_fund_path(@proposal, @fund)
        expect(current_path).to eq(apply_proposal_fund_path(@proposal, @fund))
      end
    end
  end
end
