class RecipientsController < ApplicationController
  before_filter :ensure_logged_in
  before_filter :ensure_funder
  before_filter :load_recipient

  def show
    @grants = @recipient.grants
    # render :json => @grants
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @grants }
    end
  end

  private

  def load_recipient
    @recipient = Recipient.find_by_slug(params[:id])
  end
end
