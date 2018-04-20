class RecipientsController < ApplicationController
  before_action :ensure_logged_in

  def edit
    @recipient = Recipient.find_by(slug: params[:id])
    redirect_to root_path unless @recipient
  end

  def update
    if @recipient.update(recipient_params)
      redirect_to account_organisation_path(@recipient), notice: 'Updated'
    else
      render :edit
    end
  end

  private

    def recipient_params
      params.require(:recipient).permit(
        :charity_number, :company_number, :country, :employees, :income_band,
        :name, :operating_for, :org_type, :street_address, :volunteers, :website
      )
    end
end
