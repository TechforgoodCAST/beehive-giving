require 'test_helper'

class RecipientProfilesTest < ActionDispatch::IntegrationTest

  test "cannot create profile if limit reached" do
    @recipient = create(:recipient, :founded_on => "01/01/2005")
    4.times { create(:profiles, :organisation => @recipient) }
    create_and_auth_user!(:organisation => @recipient)
    visit recipient_profiles_path(@recipient)
    assert_not page.has_content?("New profile")

    visit new_recipient_profile_path(@recipient)
    assert_equal '/funders', current_path
  end

end
