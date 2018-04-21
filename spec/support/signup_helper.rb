class SignupHelper
  include Capybara::DSL

  def complete_signup_basics_form(params = {})
    select 'Capital funding'
    select params[:org_type] || 'An unregistered organisation OR project'
    fill_in :signup_basics_charity_number, with: params[:charity_number]
    select (params[:country] || 'United Kingdom'), match: :first
    select Theme.last.name
    click_button 'Find suitable funds'
    self
  end

  def complete_signup_suitability_form(params = {})
    complete_signup_suitability_recipient
    complete_signup_suitability_proposal
    complete_signup_suitability_user(params)
    click_button 'Check suitability'
    self
  end

  def complete_signup_suitability_recipient
    fill_in :signup_suitability_recipient_name, with: 'Name'
    fill_in :signup_suitability_recipient_street_address, with: 'London Road'
    select 'Less than £10k'
    select '4 years or more'
    select 'None', from: :employees
    select '1 - 5', from: :volunteers
    self
  end

  def complete_signup_suitability_proposal
    fill_in :signup_suitability_proposal_total_costs, with: 10_000
    choose :signup_suitability_proposal_all_funding_required_true
    fill_in :signup_suitability_proposal_funding_duration, with: 12
    fill_in :signup_suitability_proposal_title, with: 'Title'
    fill_in :signup_suitability_proposal_tagline, with: 'Description'
    select 'An entire country'
    self
  end

  def complete_signup_suitability_user(params = {})
    fill_in :signup_suitability_user_first_name, with: 'J'
    fill_in :signup_suitability_user_last_name, with: 'Doe'
    fill_in :signup_suitability_user_email, with: 'j.doe@example.com'
    fill_in :signup_suitability_user_password, with: 'Pa55word'
    check :signup_suitability_user_agree_to_terms
    within '.signup_suitability_proposal_private' do
      choose params[:private] || 'Yes'
    end
    self
  end
end
