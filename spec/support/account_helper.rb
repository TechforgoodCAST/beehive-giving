
class AccountHelper
  include Capybara::DSL

  def initialize
    @user = User.last
  end

  def request_reset(email: @user.email)
    click_link 'Sign in', match: :first
    click_link 'Forgot Password?'
    fill_in :password_reset_email, with: email
    click_button 'Reset password'
    self
  end

  def set_new_password
    @user.reload
    visit "password_resets/#{@user.password_reset_token}/edit"
    fill_in :password_reset_password, with: 'password1'
    fill_in :password_reset_password_confirmation, with: 'password1'
    click_button 'Change password'
    self
  end

  def update_user
    fill_in :user_first_name, with: 'updates'
    fill_in :user_last_name, with: 'user'
    fill_in :user_email, with: 'updates.user@email.com'
    fill_in :user_password, with: 'newPa55word'
    fill_in :user_password_confirmation, with: 'newPa55word'
    click_button 'Update'
  end
end
