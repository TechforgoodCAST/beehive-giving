module ApplicationHelper
  def allow_functional_cookies?
    session[:functional_cookies].to_s != 'false'
  end

  def allow_performance_cookies?
    session[:performance_cookies].to_s != 'false'
  end
end
