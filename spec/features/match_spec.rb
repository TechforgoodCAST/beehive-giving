require 'rails_helper'
require_relative '../support/match_helper'

feature 'Match' do
  let(:helper) { MatchHelper.new }

  before(:each) do
    @app.seed_test_db.setup_funds(num: 3, open_data: true)
    @db = @app.instances
    helper.stub_charity_commission.stub_companies_house
    visit root_path
  end

  scenario 'When I sign up with an invalid email address,
            I want to be told why,
            so I can correct the mistake' do
    helper.fill_user_form(email: 'invalid_email').submit_user_form
    expect(page).to have_text 'Please enter a valid email'
  end

  scenario 'When I sign up with an invalid password,
            I want to be told why,
            so I can correct the mistake' do
    helper.fill_user_form(password: 'invaid_password').submit_user_form
    expect(page).to have_text 'Must include 6 characters with 1 number'
  end

  scenario 'When I sign up with an exisiting email,
            I want to be told to sign in,
            so I can access my account' do
    @app.with_user
    helper.fill_user_form(email: User.last.email).submit_user_form
    expect(page).to have_text "Please 'sign in' using the link above"
  end

  # TODO: inconsistent
  scenario 'When I sign up as an individual,
            I want to be directed to appropriate support,
            so I can avoid wasted effort', js: true do
    helper.fill_user_form(seeking: 'Myself OR another individual')
    within '#new_user' do
      click_link 'FAQ'
    end
    expect(current_path).to eq faq_path
  end

  scenario 'When I sign up as a project,
            I want to make sure my details are correct,
            so I feel confident my results will be accurate' do
    helper.fill_user_form(seeking: 'An unregistered organisation OR project')
          .submit_user_form.submit_organisation_form
    expect(page).to have_text "can't be blank", count: 7
  end

  def expect_charity_scrape
    expect(page).to have_selector("input[value='Centre For The Acceleration " \
                                  "Of Social Technology']")
    expect(page).to have_text "can't be blank", count: 4
    self
  end

  def expect_company_lookup
    expect(page).to have_selector("input[value='Centre For The Acceleration " \
                                  "Of Social Technology']")
    expect(find_field(:recipient_country).value).to eq 'GB'
    expect(find_field(:recipient_operating_for).value).to eq '2'
    expect(page).to have_text "can't be blank", count: 3
    self
  end

  scenario 'When I sign up as a charity that is also a company,
            I want to make sure my details are correct,
            so I feel confident my results will be accurate' do
    helper.submit_user_form!
    expect_company_lookup
  end

  scenario 'When I sign up as a charity,
            I want to make sure my details are correct,
            so I feel confident my results will be accurate' do
    helper.stub_charity_commission('123456')
          .fill_user_form(
            seeking: 'A registered charity',
            charity_number: '123456'
          )
          .submit_user_form
    expect_charity_scrape
  end

  scenario 'When I sign up as a company,
            I want to make sure my details are correct,
            so I feel confident my results will be accurate' do
    helper.fill_user_form(seeking: 'A registered company')
          .submit_user_form
    expect_company_lookup
  end

  scenario 'When I sign up as both a charity and company,
            I want to make sure my details are correct,
            so I feel confident my results will be accurate' do
    helper.fill_user_form(seeking: 'A registered charity & company')
          .submit_user_form
    expect_company_lookup
  end

  scenario 'When I sign up as another type of organisation,
            I want to make sure my details are correct,
            so I feel confident my results will be accurate' do
    helper.fill_user_form(seeking: 'Another type of organisation')
          .submit_user_form.submit_organisation_form
    expect(page).to have_text "can't be blank", count: 7
  end

  scenario 'When sign up with an existing charity number,
            I want to understand why and an admin should be notified,
            so I feel know what to expect and can get help if needed' do
    charity_number = '123456'
    helper.stub_charity_commission(charity_number)
    @app.create_admin.create_recipient(
      org_type: 1, charity_number: charity_number, company_number: nil
    ).with_user
    @db = @app.instances
    helper.fill_user_form(
      seeking: 'A registered charity', charity_number: charity_number
    ).submit_user_form
    expect(ActionMailer::Base.deliveries.last.subject)
      .to eq "#{User.last.first_name} has requested access to " +
             @db[:recipient].name
    expect(current_path).to eq unauthorised_path
  end

  scenario 'When sign up with an existing company number,
            I want to understand why and an admin should be notified,
            so I feel know what to expect and can get help if needed' do
    @app.create_admin
        .create_recipient(
          org_type: 2, charity_number: '', company_number: '09544506'
        ).with_user
    @db = @app.instances
    helper.fill_user_form(seeking: 'A registered company')
          .submit_user_form
    expect(current_path).to eq unauthorised_path
    expect(ActionMailer::Base.deliveries.last.subject)
      .to eq "#{User.last.first_name} has requested access to " +
             @db[:recipient].name
    expect(current_path).to eq unauthorised_path
  end

  scenario 'When sign up with an existing charity and company number,
            I want to understand why and an admin should be notified,
            so I feel know what to expect and can get help if needed' do
    @app.create_admin.create_recipient(
      org_type: 3, charity_number: '1161998', company_number: '09544506'
    ).with_user
    @db = @app.instances
    helper.submit_user_form!
    expect(ActionMailer::Base.deliveries.last.subject)
      .to eq "#{User.last.first_name} has requested access to " +
             @db[:recipient].name
    expect(current_path).to eq unauthorised_path
  end

  scenario 'When I have an incomplete account and sign in,
            I want to complete registation quickly,
            so I can see my results' do
    @app.with_user
    @db = @app.instances
    helper.fill_user_form(email: @db[:user].email).submit_user_form
    expect(page).to have_text "Please 'sign in' using the link above"
    click_link 'Sign in'
    fill_in :email, with: @db[:user].email
    fill_in :password, with: @db[:user].password
    click_button 'Sign in'
    expect(current_path).to eq new_signup_recipient_path
  end

  context 'unauthorised' do
    before(:each) do
      @app.create_recipient.create_admin.with_user
      @db = @app.instances
      @db[:user].lock_access_to_organisation(@db[:recipient])
    end

    scenario "When I'm waiting for access to an existing account and access
              an unauthorised area, I want to see a relevant message,
              so I understand why I was unauthorised" do
      @app.sign_in
      visit new_signup_recipient_path
      expect(current_path).to eq unauthorised_path
      visit faq_path
      expect(current_path).to eq faq_path
    end

    scenario 'When I (AdminUser) authorise a User to accesss an exisiting
              account, I want to see a confirmation page,
              so I know authorisation has succeeded' do
      expect(ActionMailer::Base.deliveries.last.subject)
        .to eq "#{User.last.first_name} has requested access to " +
               @db[:recipient].name
      visit grant_access_path(@db[:user].unlock_token)
      expect(current_path).to eq granted_access_path(@db[:user].unlock_token)
    end

    scenario "When I'm authorised on an exisiting account,
              I want to be notified,
              so I can resume my funding search" do
      visit grant_access_path(@db[:user].unlock_token)
      expect(ActionMailer::Base.deliveries.last.subject)
        .to eq 'You have been granted access to your organisation'
    end
  end

  scenario "When I complete my first funding proposal,
            I want to see a shortlist of the most relevant funds,
            so I feel I've found suitable funding opportunities" do
    helper.submit_user_form!
    expect(current_path).to eq new_signup_recipient_path

    {
      org_type: '3',
      charity_number: '1161998',
      company_number: '09544506',
      name: 'Centre For The Acceleration Of Social Technology',
      country: 'GB',
      operating_for: '2',
      website: 'http://www.wearecast.org.uk'
    }.each do |k, v|
      expect(find_field("recipient_#{k}").value).to eq v
    end

    helper.submit_organisation_form!
    expect(current_path).to eq new_signup_proposal_path

    helper.submit_proposal_form
    expect(current_path).to eq proposal_funds_path(Proposal.last)
    expect(page).to have_css '.fs22', count: 3

    click_link 'Hidden fund', match: :first
    expect(current_path)
      .to eq hidden_proposal_fund_path(Proposal.last, Fund.third)
  end
end
