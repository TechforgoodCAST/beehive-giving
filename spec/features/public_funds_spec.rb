require 'rails_helper'

feature 'PublicFunds' do
  before(:each) do
    @app.seed_test_db.setup_funds(num: 7, open_data: true)
    @public_fund = Fund.first
    @private_fund = Fund.last
  end

  context 'public_funds#index' do
    before(:each) do
      visit public_funds_path
    end

    scenario 'logged_in? redirects to funds#index' do
      @app.create_recipient.with_user.create_registered_proposal.sign_in
      proposal = @app.instances[:registered_proposal]

      visit public_funds_path
      expect(current_path).to eq proposal_funds_path(proposal)
    end

    scenario 'navigate' do
      visit root_path
      click_link 'Funds'
      expect(current_path).to eq public_funds_path
    end

    scenario 'public fund visible' do
      expect(page).to have_css('a.fs22', count: 3)
    end

    scenario 'private fund redacted' do
      expect(page).to have_css('.fs22.redacted', count: 3)
    end

    scenario 'can click visible fund' do
      click_link @public_fund.name
      expect(current_path).to eq public_fund_path(@public_fund)
    end

    scenario 'page 2 all redacted' do
      click_link '2'
      expect(page).to have_css('.fs22.redacted', count: 1)
    end
  end

  context 'public_funds#show' do
    scenario 'logged_in? redirects to funds#show' do
      @app.create_recipient.with_user.create_registered_proposal.sign_in
      proposal = @app.instances[:registered_proposal]

      visit public_fund_path(@public_fund)
      expect(current_path).to eq proposal_funds_path(proposal)
    end

    scenario 'visit public fund' do
      visit public_fund_path(@public_fund)
      expect(current_path).to eq public_fund_path(@public_fund)
    end

    scenario 'visit private fund' do
      visit public_fund_path(@private_fund)
      expect(current_path).to eq public_funds_path
    end

    scenario 'missing fund' do
      visit public_fund_path('missing')
      expect(current_path).to eq public_funds_path
    end
  end
end
