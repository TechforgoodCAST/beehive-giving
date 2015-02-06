class PagesController < ApplicationController
  before_filter :check_logged_in

  def check_logged_in
    if current_user.nil?
      @logged_in = false
    else
      @logged_in = true
    end
  end
end
