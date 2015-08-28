class PagesController < ApplicationController

  def tour
    redirect_to "/welcome#tell-me-more"
  end
  
end
