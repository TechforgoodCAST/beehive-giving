class PagesController < ApplicationController
  def preview
    @user = User.new
    @fund = Fund.active.where(
      "? IN (SELECT lower(
        regexp_replace(
          regexp_replace(jsonb_array_elements_text(tags), ' ', '-', 'g'),
        ',', '', 'g')
      ))", params[:tag]
    ).order(open_data: :desc).first
    @tag = params[:tag].tr('-', ' ')

    redirect_to root_path unless @fund
  end

  def privacy
    session[:read_cookies_notice] = true if params[:read_cookies_notice]
  end
end
