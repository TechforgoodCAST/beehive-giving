class PagesController < ApplicationController

  def about
    redirect_to signup_user_path
  end

  def tour
    redirect_to "/welcome#tell-me-more"
  end

  def faq; end

end
