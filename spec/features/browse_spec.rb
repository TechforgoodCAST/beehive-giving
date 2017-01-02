require 'rails_helper'

feature 'Browse' do
  before(:each) do
    @app.seed_test_db
        .setup_funds(num: 7, open_data: true)
        .tag_funds
        .create_recipient
        .with_user
        .create_registered_proposal
    @db = @app.instances
    visit sign_in_path
  end

  scenario 'When I sign in,
            I want to see my recommended fund,
            so I can see my results' do
    fill_in :email, with: @db[:user].user_email
    fill_in :password, with: @db[:user].password
    click_button 'Sign in'
    expect(current_path).to eq recommended_funds_path
  end

  context 'signed in' do
    before(:each) do
      @unsuitable_fund = Fund.first
      @low_fund = Fund.find_by(name: 'Awards for All 2')
      @top_fund = Fund.last
      @app.sign_in
      visit root_path
    end

    scenario "When I find a recommended fund I'm interested in,
              I want to view more details,
              so I can decide if I want to apply" do
      expect(page).to_not have_text @unsuitable_fund.name
      click_link @low_fund.name
      expect(current_path).to eq fund_path(@low_fund)
    end

    scenario 'When I click for more details on a fund card,
              I want to see more details about the fund,
              so I can decide if I want to apply' do
      within '.card-cta', match: :first do
        click_link 'More info'
      end
      expect(current_path).to eq fund_path(@top_fund)
    end

    scenario 'When I click for more details on funding distribution,
              I want to see a column chart of funding distribution,
              so I can decide if I want to apply' do
      click_link 'More info', href: fund_path(@top_fund, anchor: 'how-was-funding-distributed')
      expect(current_path).to eq fund_path(@top_fund)
    end

    scenario 'When I click for more details on geographic scale,
              I want to see a geo chart of geographic scale,
              so I can decide if I want to apply' do
      click_link 'More info', href: fund_path(@top_fund, anchor: 'where-was-funding-awarded')
      expect(current_path).to eq fund_path(@top_fund)
    end

    scenario "When I find a funding theme I'm interested in,
              I want to see similar funds,
              so I can discover new funding opportunties" do
      click_link 'Arts', match: :first
      expect(current_path).to eq tag_path('arts')
      expect(page).to have_css '.funder', count: 7
      expect(page).to have_css '.locked-funder', count: 6
    end

    scenario "When I navigate to 'Recommended' funds,
              I want to see my recommended funds,
              so I compare them" do
      click_link 'Recommended'
      expect(current_path).to eq recommended_funds_path
    end

    context 'all_funds_path' do
      before(:each) do
        click_link 'All'
      end

      scenario "When I find a recommended fund I'm interested in,
                I want to view more details,
                so I can decide if I want to apply" do
        click_link @unsuitable_fund.name
        expect(current_path).to eq fund_path(@unsuitable_fund)
      end

      scenario "When navigate to 'All' funds,
                I want to see my all funds on site,
                so I can see which ones I already and the value of the site" do
        expect(current_path).to eq all_funds_path
      end

      scenario "When I'm browsing 'All' funds and can only see tags for recommended funds,
                I want more information,
                so I understand why I can't see some information" do
        expect(page).to have_css '.redacted', count: 6
      end
    end

    context 'When I view fund a with open data' do
      before(:each) do
        click_link @top_fund.name
      end

      scenario 'I want to see which time period the analysis relates to,
                so I can understand how up to date it is' do
        expect(page).to have_text 1.year.ago.strftime("%b %y'") +
                                  ' - ' +
                                  Time.zone.today.strftime("%b %y'"),
                                  count: 4
      end

      scenario 'I want to see the grant_count,
                so I can evaluate my chances of success' do
        expect(page).to have_text "Awarded #{@top_fund.grant_count} grants.", count: 2
      end

      scenario 'I want to see a amount_awarded_distribution chart,
                so I can evaluate how much funding to ask for' do
        expect(page).to have_css '#amount_awarded_distribution'
      end

      scenario 'I want to see the top_award_months,
                so I can evaluate my chances of success' do
        expect(page).to have_text 'Awarded the most funding in January and February.', count: 2
      end

      scenario "I want to see a award_month_distribution chart,
                so I can understand which months funding is awarded" do
        expect(page).to have_css '#award_month_distribution'
      end

      scenario 'I want to see the top_countries,
                so I can evaluate my chances of success' do
        expect(page).to have_text 'Awarded most funding in the United Kingdom.', count: 2
      end

      scenario "I want to see a country_distribution chart,
                so I can understand in which countries funding is awarded" do
        expect(page).to have_css '#country_distribution'
      end

      scenario 'more info links'
    end
  end
end
