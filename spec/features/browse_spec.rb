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
    @proposal = @db[:registered_proposal]
    visit sign_in_path
  end

  scenario 'When I sign in,
            I want to see my recommended fund,
            so I can see my results' do
    fill_in :email, with: @db[:user].email
    fill_in :password, with: @db[:user].password
    click_button 'Sign in'
    expect(current_path).to eq recommended_proposal_funds_path(@proposal)
  end

  context 'signed in' do
    before(:each) do
      @unsuitable_fund = Fund.first
      @low_fund = Fund.find_by(name: 'Awards for All 2')
      @top_fund = Fund.last
      @recipient = @db[:recipient]
      @app.sign_in
      visit root_path
    end

    scenario "When I find a recommended fund I'm interested in,
              I want to view more details,
              so I can decide if I want to apply" do
      expect(page).to_not have_text @unsuitable_fund.name
      click_link @low_fund.name
      expect(current_path).to eq proposal_fund_path(@proposal, @low_fund)
    end

    scenario 'When I click for more details on a fund card,
              I want to see more details about the fund,
              so I can decide if I want to apply' do
      within '.card-cta', match: :first do
        click_link 'More info'
      end
      expect(current_path).to eq proposal_fund_path(@proposal, @top_fund)
    end

    scenario "When I visit a fund that doesn't exist,
               I want to be redirected to where I came from and see a message,
               so I avoid an error and understand what happened" do
      visit proposal_fund_path(@proposal, 'missing-fund')
      expect(current_path).to eq recommended_proposal_funds_path(@proposal)
    end

    scenario 'When I click for more details on funding distribution,
              I want to see a column chart of funding distribution,
              so I can decide if I want to apply' do
      click_link 'More info', href: proposal_fund_path(
        @proposal, @top_fund, anchor: 'how-was-funding-distributed'
      )
      expect(current_path).to eq proposal_fund_path(@proposal, @top_fund)
    end

    scenario 'When I click for more details on geographic scale,
              I want to see a geo chart of geographic scale,
              so I can decide if I want to apply' do
      click_link 'More info', href: proposal_fund_path(
        @proposal, @top_fund, anchor: 'where-was-funding-awarded'
      )
      expect(current_path).to eq proposal_fund_path(@proposal, @top_fund)
    end

    scenario "When I find a funding theme I'm interested in,
              I want to see similar funds,
              so I can discover new funding opportunties" do
      click_link 'Arts', match: :first
      expect(current_path).to eq tag_proposal_funds_path(@proposal, 'arts')
      expect(page).to have_css '.card', count: 7
      expect(page).to have_css '.locked-fund', count: 6
    end

    scenario "When I visit a funding theme which isn't listed,
              I want to see a message and be directed to safety,
              so I can continue my search" do
      visit tag_proposal_funds_path(@proposal, '')
      expect(page.all('body script', visible: false)[0].native.text)
        .to have_text 'Fund not found'
      expect(current_path).to eq recommended_proposal_funds_path(@proposal)

      visit tag_proposal_funds_path(@proposal, 'missing')
      expect(page.all('body script', visible: false)[0].native.text)
        .to have_text 'Not found'
      expect(current_path).to eq recommended_proposal_funds_path(@proposal)
    end

    scenario "When I navigate to 'Recommended' funds,
              I want to see my recommended funds,
              so I compare them" do
      click_link 'Recommended'
      expect(current_path).to eq recommended_proposal_funds_path(@proposal)
    end

    def subscribe_and_visit(path)
      @recipient.subscribe!
      visit path
      expect(current_path).to eq path
    end

    scenario 'can only view proposal_fund_path for recommended funds ' \
              'unless subscribed' do
      visit proposal_fund_path(@proposal, Fund.first)
      expect(current_path).to eq account_upgrade_path(@recipient)

      subscribe_and_visit proposal_fund_path(@proposal, Fund.first)
    end

    scenario 'can only view eligibility_proposal_fund_path for ' \
              'recommended funds unless subscribed' do
      visit eligibility_proposal_fund_path(@proposal, Fund.first)
      expect(current_path).to eq account_upgrade_path(@recipient)

      subscribe_and_visit eligibility_proposal_fund_path(@proposal, Fund.first)
    end

    scenario 'only recommended funds shown unless subscribed' do
      visit all_proposal_funds_path(@proposal)
      expect(page).to have_css '.yellow.redacted.large', count: 1

      subscribe_and_visit all_proposal_funds_path(@proposal)
    end

    scenario 'only recommended funds shown unless subscribed' do
      data = { Fund.first.slug => { eligible: true, count_failing: 0 } }
      @proposal.update!(eligibility: data)
      visit eligible_proposal_funds_path(@proposal)
      expect(page).to have_css '.yellow.redacted.large', count: 1

      subscribe_and_visit eligible_proposal_funds_path(@proposal)
    end

    scenario 'only recommended funds shown unless subscribed' do
      data = { Fund.first.slug => { eligible: false, count_failing: 1 } }
      @proposal.update!(eligibility: data)
      visit ineligible_proposal_funds_path(@proposal)
      expect(page).to have_css '.yellow.redacted.large', count: 1

      subscribe_and_visit ineligible_proposal_funds_path(@proposal)
    end

    context 'all_funds_path' do
      before(:each) do
        click_link 'All'
      end

      scenario "When I find a recommended fund I'm interested in,
                I want to view more details,
                so I can decide if I want to apply" do
        click_link @top_fund.name
        expect(current_path).to eq proposal_fund_path(
          @proposal, @top_fund
        )
      end

      scenario "When navigate to 'All' funds,
                I want to see my all funds on site,
                so I can see which ones I already and the value of the site" do
        expect(current_path).to eq all_proposal_funds_path(@proposal)
      end
    end

    context 'When I view fund a with open data' do
      before(:each) do
        click_link @top_fund.name
      end

      scenario 'I want to see which time period the analysis relates to,
                so I can understand how up to date it is' do
        expect(page).to have_text 1.year.ago.strftime("%b %Y") +
                                  ' - ' +
                                  Time.zone.today.strftime("%b %Y"),
                                  count: 4
      end

      scenario 'I want to see the grant_count,
                so I can evaluate my chances of success' do
        expect(page).to have_text(
          "Awarded #{@top_fund.grant_count} grants.", count: 2
        )
      end

      scenario 'I want to see a amount_awarded_distribution chart,
                so I can evaluate how much funding to ask for' do
        expect(page).to have_css '#amount_awarded_distribution'
      end

      scenario 'I want to see the top_award_months,
                so I can evaluate my chances of success' do
        expect(page).to have_text(
          'Awarded the most funding in January and February.', count: 2
        )
      end

      scenario "I want to see a award_month_distribution chart,
                so I can understand which months funding is awarded" do
        expect(page).to have_css '#award_month_distribution'
      end

      scenario 'I want to see the top_countries,
                so I can evaluate my chances of success' do
        expect(page).to have_text(
          'Awarded most funding in the United Kingdom.', count: 2
        )
      end

      scenario "I want to see a country_distribution chart,
                so I can understand in which countries funding is awarded" do
        expect(page).to have_css '#country_distribution'
      end

      scenario 'I want to see the sources of open data,
                so I can further my research' do
        click_link 'Sources'
        json = { 'https://creativecommons.org/licenses/by/4.0/':
                 'http://www.example.com' }.to_json
        expect(page.body).to eq json
        expect(page.response_headers['Content-Type'])
          .to eq 'application/json; charset=utf-8'
      end
    end
  end
end
