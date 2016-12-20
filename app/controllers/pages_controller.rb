class PagesController < ApplicationController
  def about
    redirect_to signup_user_path
  end

  def tour
    redirect_to '/welcome#tell-me-more'
  end

  def faq
    @recipient = current_user.organisation if @logged_in
  end
end
