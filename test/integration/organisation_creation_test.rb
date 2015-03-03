require 'test_helper'

class OrganisationCreationTest < ActionDispatch::IntegrationTest

  setup do

  end

  test 'You get redirected when visiting the page when not signed in' do
    visit '/your-organisation'
    assert_equal current_path, '/welcome'
  end

  # test 'if you are signed and you have an organisation you get redirected your dashboard' do
  #   @organisation = create(:recipient)
  #   @user = create(:user, :organisation => @organisation)
  #   cookies[:auth_token] = @user.auth_token
  #   visit '/your-organisation'
  #   assert_equal '/dashboard', current_path
  # end

  # test if you are signed in and have no organisation you can see the organise page (/your-organisation)

  # test filling in form correctly submits, saves record and redirects to correct page

  # test filling form incorrectly causes validation to trigger - try difference scenarios

end
