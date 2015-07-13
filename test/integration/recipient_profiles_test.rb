require 'test_helper'

class RecipientProfilesTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient, :founded_on => "01/01/2005")
    @profile = create(:profile, :organisation => @recipient, :year => Date.today.year)
    create_and_auth_user!(:organisation => @recipient)
  end

  test 'new profile link is hidden if annual profile limit is reached' do
    visit recipient_profiles_path(@recipient)
    assert_not page.has_content?("New profile")
  end

  test 'recipients can only create one profile a year' do
    visit new_recipient_profile_path(@recipient)
    assert_equal edit_recipient_profile_path(@recipient, @profile), current_path
  end

  test 'that clicking the call to action takes you the new profile page' do
    @recipient.profiles.last.destroy
    visit funders_path
    find_link('Refine your results').click
    assert_equal new_recipient_profile_path(@recipient), current_path
  end

  test 'new profile page redirects to edit when profile exisits for current year' do
    visit new_recipient_profile_path(@recipient)
    assert_equal edit_recipient_profile_path(@recipient, @profile), current_path
  end

end
