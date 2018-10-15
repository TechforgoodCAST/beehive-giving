module ApplicationHelper
  def allow_functional_cookies?
    session[:functional_cookies].to_s != 'false'
  end

  def allow_performance_cookies?
    session[:performance_cookies].to_s != 'false'
  end

  def obscure_email(email)
    email.gsub(/(?<=.{2})(.*)@/, '...@')
  end
end
