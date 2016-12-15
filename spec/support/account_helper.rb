class AccountHelper
  include Capybara::DSL

  def initialize
    @user = User.last
  end

  def request_reset(email: @user.user_email)
    click_link 'Sign in'
    click_link 'Forgot Password?'
    fill_in :user_email, with: email
    click_button 'Reset password'
    self
  end

  def set_new_password
    @user.reload
    visit "password_resets/#{@user.password_reset_token}/edit"
    fill_in :user_password, with: 'password1'
    fill_in :user_password_confirmation, with: 'password1'
    click_button 'Change password'
    self
  end
end
