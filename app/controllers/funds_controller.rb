class FundsController < ApplicationController
  before_action :ensure_logged_in, :ensure_proposal_present

  def show
    @fund = Fund.includes(:funder).find_by(slug: params[:id])
  end

  def tagged
    @tag = params[:tag].tr('-', ' ').capitalize
    @funds = Fund.includes(:funder).where('tags ?| array[:tags]', tags: @tag)
    redirect_to root_path, alert: 'Not found' if @funds.empty?
  end
end
