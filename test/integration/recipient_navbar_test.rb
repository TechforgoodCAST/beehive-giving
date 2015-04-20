require 'test_helper'

class RecipientNavbarTest < ActionDispatch::IntegrationTest

  setup do
  end

  test 'logo click whilst unregistered sends to user#signup' do
    visit '/about'
    find(:css, '.logo.uk-hidden-small').click
    assert_equal '/welcome', current_path
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
