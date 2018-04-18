class SignupHelper
  include Capybara::DSL

  def complete_signup_basics_form
    select 'Capital funding'
    select 'An unregistered organisation OR project'
    select 'United Kingdom', match: :first
    select 'Theme1'
    click_button 'Find suitable funds'
    self
  end

  def complete_signup_suitability_form
    complete_signup_suitability_recipient
    complete_signup_suitability_proposal
    complete_signup_suitability_user
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

  def complete_signup_suitability_user
    fill_in :signup_suitability_user_first_name, with: 'J'
    fill_in :signup_suitability_user_last_name, with: 'Doe'
    fill_in :signup_suitability_user_email, with: 'j.doe@example.com'
    fill_in :signup_suitability_user_password, with: 'Pa55word'
    check :signup_suitability_user_agree_to_terms
    choose :signup_suitability_proposal_private_true
    self
  end
end