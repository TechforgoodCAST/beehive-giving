require 'test_helper'

class RecipientProfilesTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient, :founded_on => "01/01/2005")
    create_and_auth_user!(:organisation => @recipient)
  end

  test 'new profile link is hidden if annual profile limit is reached' do
    create(:profile, :organisation => @recipient, :year => Date.today.year)
    visit recipient_profiles_path(@recipient)
    assert_not page.has_content?("New profile")
  end

  test 'recipients can only create one profile a year' do
    @profile = create(:profile, :organisation => @recipient, :year => Date.today.year)
    visit new_recipient_profile_path(@recipient)
    assert_equal edit_recipient_profile_path(@recipient, @profile), current_path
  end

  test 'new profile page redirects to edit when profile exisits for current year' do
    @profile = create(:profile, :organisation => @recipient, :year => Date.today.year)
    visit new_recipient_profile_path(@recipient)
    assert_equal edit_recipient_profile_path(@recipient, @profile), current_path
  end

  test 'profile missing for current year redirects to new profile page' do
    @profile = create(:profile, :organisation => @recipient, :year => Date.today.year-1)
    @funder = create(:funder)

    visit recommended_funders_path
    assert_equal new_recipient_profile_path(@recipient), current_path
    assert page.has_content?('Your profile is out of date')

    visit eligible_funders_path
    assert_equal new_recipient_profile_path(@recipient), current_path

    visit ineligible_funders_path
    assert_equal new_recipient_profile_path(@recipient), current_path

    visit all_funders_path
    assert_equal new_recipient_profile_path(@recipient), current_path

    visit recipient_eligibility_path(@funder)
    assert_equal new_recipient_profile_path(@recipient), current_path

    visit recipient_apply_path(@funder)
    assert_equal new_recipient_profile_path(@recipient), current_path

    visit funder_path(@funder)
    assert_equal new_recipient_profile_path(@recipient), current_path

    visit recipient_profiles_path(@recipient)
    assert_equal new_recipient_profile_path(@recipient), current_path

    visit edit_recipient_profile_path(@recipient, @profile)
    assert_equal new_recipient_profile_path(@recipient), current_path
  end

  def complete_beneficiaries_section
    create(:country)
    @beneficiaries = Array.new(3) { create(:beneficiary) }
    visit new_recipient_profile_path(@recipient)
    assert_equal new_recipient_profile_path(@recipient), current_path
    within('#new_profile') do
      check("profile_beneficiary_ids_#{@beneficiaries[0].id}")
      select(Profile::GENDERS.sample, :from => 'profile_gender')
      fill_in('profile_min_age', :with => 0)
      fill_in('profile_max_age', :with => 120)
    end
    click_button('Next')
  end

  test 'complete beneficiaries section' do
    complete_beneficiaries_section
    assert_equal edit_recipient_profile_path(@recipient, @recipient.profiles.first), current_path
    assert_equal 'location', @recipient.profiles.first.state
  end

  def complete_location_section
    3.times { create(:country) }
    3.times { create(:district) }
    complete_beneficiaries_section
    @profile = @recipient.profiles.first
    within("#edit_profile_#{@profile.id}") do
      select('United Kingdom', :from => 'profile_country_ids', :match => :first)
      select('Other', :from => 'profile_district_ids', :match => :first)
    end
    click_button('Next')
  end

  test 'complete location section' do
    complete_location_section
    assert_equal 'team', @recipient.profiles.first.state
  end

  test 'country completed if multi national' do
    @recipient.update_attribute(:multi_national, true)
    complete_beneficiaries_section
    assert @recipient.multi_national?
    assert page.has_css?('.uk-hidden', count: 0)
    # Selenium?
  end

  test 'country blank if not not multi national' do
    complete_beneficiaries_section
    assert_not @recipient.multi_national?
    assert page.has_css?('.uk-hidden', count: 2)
  end

  # # Selenium
  # test 'countries field toggle' do
  #   Capybara.current_driver = :selenium
  #   browser = Capybara.current_session.driver.browser
  #   browser.manage.add_cookie(name: :auth_token, value: @user.auth_token)
  #
  #   visit sign_in_path
  #   within("#sign-in") do
  #     fill_in('email', :with => @user.user_email)
  #     fill_in('password', :with => @user.password)
  #   end
  #   click_button 'Sign in'
  #
  #   complete_beneficiaries_section
  #   assert page.has_css?('.uk-hidden', count: 2)
  #   click('Work in another country?')
  #   assert page.has_css?('.uk-hidden', count: 0)
  # end

  def complete_team_section
    @implementors = Array.new(3) { create(:implementor) }
    complete_location_section
    within("#edit_profile_#{@profile.id}") do
      fill_in('profile_staff_count', :with => 1)
      fill_in('profile_volunteer_count', :with => 0)
      fill_in('profile_trustee_count', :with => 0)
      check("profile_implementor_ids_#{@implementors[0].id}")
    end
    click_button('Next')
  end

  test 'complete team section' do
    complete_team_section
    assert_equal 'work', @recipient.profiles.first.state
  end

  def complete_work_section
    @implementations = Array.new(3) { create(:implementation) }
    complete_team_section
    within("#edit_profile_#{@profile.id}") do
      check("profile_implementation_ids_#{@implementations[0].id}")
      choose('Yes')
    end
    click_button('Next')
  end

  test 'complete work section' do
    complete_work_section
    assert_equal 'finance', @recipient.profiles.first.state
  end

  def complete_finance_section
    complete_work_section
    within("#edit_profile_#{@profile.id}") do
      fill_in('profile_income', :with => 0)
      check('profile_income_actual')
      fill_in('profile_expenditure', :with => 0)
    end
    click_button('Next')
  end

  test 'complete finance section' do
    complete_finance_section
    assert_equal 'complete', @recipient.profiles.first.state
  end

  test 'initial profile completion redirects to recommended funders path' do
    complete_finance_section
    assert_equal recommended_funders_path, current_path
  end

  test 'editing complete profile shows entire form' do
    @profile = create(:profile, :organisation => @recipient, :year => Date.today.year, :state => 'complete')
    visit edit_recipient_profile_path(@recipient, @profile)
    assert page.has_content?('countries')
  end

  test 'updating profile updates proposal recommendation if present' do
    setup_funders(3)
    @funders[0].grants.each { |g| g.update_column(:amount_awarded, 1000) }
    @funders[1].grants.each { |g| g.update_column(:amount_awarded, 1000) }
    @profile = create(:profile, :organisation => @recipient, :year => Date.today.year, :state => 'complete')
    @recipient.refined_recommendation

    assert_equal 2, @recipient.load_recommendation(@funders.last).score

    create(:proposal, recipient: @recipient, activity_costs: 2500, people_costs: 2500, capital_costs: 2500, other_costs: 2500)

    assert_equal 1, @recipient.load_recommendation(@funders.last).grant_amount_recommendation
    assert_equal 3, @recipient.load_recommendation(@funders.last).total_recommendation

    @profile.countries.last.destroy
    @recipient.refined_recommendation

    assert_equal 1.1, @recipient.load_recommendation(@funders.last).score
    assert_equal 2.1, @recipient.load_recommendation(@funders.last).total_recommendation
  end

  def setup_for_scrape
    # charity must have year ending, employees, volunteers, and trustee data
    @recipient.charity_number = '1113988'
    @recipient.get_charity_data
    @recipient.save
  end

  test 'team scrape data shown if available' do
    setup_for_scrape
    complete_location_section
    assert page.has_content?('According to the Charity Commission', count: 3)
  end

  test 'financial scrape data shown if available' do
    setup_for_scrape
    complete_work_section
    assert page.has_content?('According to the Charity Commission', count: 2)
  end

end
