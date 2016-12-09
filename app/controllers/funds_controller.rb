class FundsController < ApplicationController
  before_action :ensure_logged_in, :load_recipient, :ensure_proposal_present,
                :load_proposal

  def show
    @fund = Fund.includes(:funder).find_by(slug: params[:id])
  end

  def tagged
    @tag = ActsAsTaggableOn::Tag.find_by(slug: params[:tag])
    if @tag.present?
      @funds = @recipient.funds.includes(:funder).tagged_with(@tag)
    else
      redirect_to root_path, alert: 'Not found'
    end
  end
end
