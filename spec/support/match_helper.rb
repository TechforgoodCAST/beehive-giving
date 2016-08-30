class MatchHelper

  include Capybara::DSL
  include WebMock::API

  def stub_charity_commission
    body = File.read(Rails.root.join('spec', 'support', 'charity_commision_scrape_stub.html'))
    # TODO: dynamic url?
    stub_request(:get, "http://beta.charitycommission.gov.uk/charity-details/?regid=1161998&subid=0")
      .to_return(status: 200, body: body)
    self
  end

  def stub_companies_house
    body = File.read(Rails.root.join('spec', 'support', 'companies_house_scrape_stub.html'))
    # TODO: dynamic url?
    stub_request(:get, 'https://beta.companieshouse.gov.uk/company/09544506')
      .to_return(status: 200, body: body)
    self
  end

  def fill_user_form
    within('#new_user') do
      fill_in :user_first_name,     with: 'Jack'
      fill_in :user_last_name,      with: 'Bauer'
      select  'A registered charity'
      fill_in :user_charity_number, with: '1161998'
      fill_in :user_user_email,     with: 'jack@ctu.org'
      fill_in :user_password,       with: '123abc'
      check   :user_agree_to_terms
      # TODO: test cases for other types of org
    end
    self
  end

  def submit_user_form
    fill_user_form
    click_button 'Create an account (for free!)'
    self
  end

  def fill_organisation_form
    # TODO: test cases for other types of org
    within('#new_recipient') do
      select '£100k - £1m'
      select '1 - 5', from: 'recipient_employees'
      select '1 - 5', from: 'recipient_volunteers'
    end
    self
  end

  def submit_organisation_form
    fill_organisation_form
    click_button 'Next'
    self
  end

  def fill_proposal_form
    # Requirements
    select 'Mostly financial'
    fill_in :proposal_funding_duration, with: 12
    select 'Revenue funding - running costs, salaries and activity costs'
    fill_in :proposal_total_costs, with: 10000.0

    # Beneficiaries
    choose :proposal_all_funding_required_true
    select 'All genders'
    check "proposal_age_group_ids_#{AgeGroup.first.id}"
    choose :proposal_affect_people_true
    Beneficiary.where(category: 'People').each do |b|
      check "proposal_beneficiary_ids_#{b.id}"
    end
    choose :proposal_affect_other_false

    # Location
    choose 'An entire country'
    select Country.first.name # TODO: js testing
    
    # Privacy
    choose :proposal_private_false

    self
  end

  def submit_proposal_form
    fill_proposal_form
    click_button 'Save and recommend funders'
    self
  end

end
