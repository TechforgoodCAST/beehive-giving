module SignInHelper
  include Capybara::DSL

  def complete_sign_in_lookup(email)
    visit(sign_in_lookup_path)
    fill_in(:sign_in_lookup_email, with: email)
    click_button('Next')
  end

  def complete_sign_in_auth(password, remember_me = false)
    fill_in(:sign_in_auth_password, with: password)
    check(:sign_in_auth_remember_me) if remember_me
    click_button('Sign in')
  end

  def sign_in(user, opts = {})
    complete_sign_in_lookup(opts[:email] || user.email)
    complete_sign_in_auth(opts[:password] || user.password, opts[:remember_me])
  end
end
