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

  def complete_beneficiaries_section
    @beneficiaries = Array.new(3) { create(:beneficiary) }
    visit new_recipient_profile_path(@recipient)
    assert_equal new_recipient_profile_path(@recipient), current_path
    within('#new_profile') do
      check("profile_beneficiary_ids_#{@beneficiaries[0].id}")
      select(Profile::GENDERS.sample, :from => 'profile_gender')
      fill_in('profile_min_age', :with => 0)
      fill_in('profile_max_age', :with => 120)
    end
    click_button('Save')
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
      fill_in('profile_beneficiaries_count', :with => 0)
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

  test 'initial profile completion redirects to recommendations on funders index' do
    complete_finance_section
    assert_equal funders_path, current_path
  end

  test 'editing complete profile shows entire form' do
    @profile = create(:profile, :organisation => @recipient, :year => Date.today.year, :state => 'complete')
    visit edit_recipient_profile_path(@recipient, @profile)
    assert page.has_content?('Location')
  end

  # test 'editing complete profile redirects to previous path on success' do
  #   @profile = create(:profile, :organisation => @recipient, :year => Date.today.year, :state => 'complete')
  #   visit recipient_profiles_path(@recipient)
  #   visit edit_recipient_profile_path(@recipient, @profile)
  #   within("#edit_profile_#{@profile.id}") do
  #     fill_in('profile_income', :with => 1000000)
  #   end
  #   click_button('Save')
  #   assert_equal recipient_profiles_path(@recipient), current_path
  # end

end
