class RecipientsController < ApplicationController
  before_filter :ensure_logged_in
  # before_filter :ensure_funder
  before_filter :load_recipient

  def show
    @grants = @recipient.grants
    @funder = current_user.organisation
  end

  def dashboard
    @funders = Funder.all
  end

  def comparison
    @funder = Funder.find_by_slug(params[:id])
  end

  private

  def load_recipient
    @recipient = Recipient.find_by_slug(params[:id])
  end
end
