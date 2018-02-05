class MatchHelper
  include Capybara::DSL
  include WebMock::API

  def stub_charity_commission(number = '1161998')
    # TODO: refactor
    stub_request(:get, 'http://beta.charitycommission.gov.uk/charity-details/?regid=&subid=0')
      .to_return(status: 200, body: [])

    body = File.read(Rails.root.join('spec', 'support', "charity_commision_scrape_stub_#{number}.html"))
    stub_request(:get, "http://beta.charitycommission.gov.uk/charity-details/?regid=#{number}&subid=0")
      .to_return(status: 200, body: body)
    self
  end

  def stub_companies_house(
    file: 'companies_house_full_stub.json',
    number: '09544506',
    content_type: 'application/json'
  )
    body = File.read(Rails.root.join('spec', 'support', file))
    endpoint = 'http://data.companieshouse.gov.uk/doc/company/'
    stub_request(:get, endpoint + number + '.json')
      .to_return(
        status: 200,
        body: body,
        headers: { 'Content-Type' => content_type }
      )
    self
  end

  def fill_user_form(
    email: 'jack@ctu.org', password: '123abc',
    seeking: 'A registered charity', charity_number: '1161998',
    company_number: '09544506'
  )
    within '#new_user' do
      fill_in :user_first_name, with: 'Jack'
      fill_in :user_last_name,  with: 'Bauer'
      select  seeking
      unless seeking == 'Myself OR another individual'
        case seeking
        when 'A registered charity'
          fill_in :user_charity_number, with: charity_number
        when 'A registered company'
          fill_in :user_company_number, with: company_number
        when 'A registered charity & company'
          fill_in :user_charity_number, with: charity_number
          fill_in :user_company_number, with: company_number
        end
        fill_in :user_email, with: email
        fill_in :user_password,   with: password
        check   :user_agree_to_terms
      end
    end
    self
  end

  def submit_user_form
    click_button 'Create account'
    self
  end

  def submit_user_form!
    fill_user_form
    submit_user_form
    self
  end

  def fill_organisation_form
    # TODO: test cases for other types of org
    within '#new_recipient' do
      select '£100k - £999k'
      select '1 - 5', from: 'recipient_employees'
      select '1 - 5', from: 'recipient_volunteers'
    end
    self
  end

  def submit_organisation_form
    click_button 'Next'
  end

  def submit_organisation_form!
    fill_organisation_form
    submit_organisation_form
    self
  end

  def fill_proposal_form
    # Requirements
    select 'Mostly financial'
    fill_in :proposal_funding_duration, with: 12
    select 'Revenue funding - running costs, salaries and activity costs'
    fill_in :proposal_total_costs, with: 10_000.0
    choose :proposal_all_funding_required_true

    # Beneficiaries
    choose :proposal_affect_people_true
    select 'All genders'
    check "proposal_age_group_ids_#{AgeGroup.first.id}"

    # Location
    choose 'An entire country'
    select Country.first.name # TODO: js testing

    # Themes
    Theme.limit(3).each do |t|
      check "proposal_theme_ids_#{t.id}"
    end

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
