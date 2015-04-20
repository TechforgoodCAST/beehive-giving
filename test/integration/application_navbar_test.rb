require 'test_helper'

class ApplicationNavbarTest < ActionDispatch::IntegrationTest

  setup do
    @recipient = create(:recipient)
    create_and_auth_user!(:organisation => @recipient)
  end

  test 'logo click whilst unregistered sends to user#signup' do
  end

  test 'logo click with user sends to find?' do
  end

  test 'logo click with organisation sends to dashboard' do
  end

  test 'logo click with profile sends to ?' do
  end

  test 'clicking Funders redirects to funders_path' do
  end

  test 'clicking Dashboard redirects to recipient_dashboard_path' do
  end

  test 'user icon opens drop down' do
  end

  test 'clicking Edit profiled redirects to recipient_profiles_path' do
  end

end
