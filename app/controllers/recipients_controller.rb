class RecipientsController < ApplicationController
  before_action :ensure_logged_in
  # TODO: before_action :check_organisation_ownership, only: :show

  def edit
    @scrape_success = @recipient.scrape_org
    redirect_to root_path if @recipient.save
  end

  def update
    @recipient.assign_attributes(recipient_params)
    @scrape_success = @recipient.scrape_org
    respond_to do |format|
      if @recipient.save
        format.js do
          render js: "window.location.href =
                      '#{new_recipient_proposal_path(@recipient)}';

                      $('button[type=submit]').prop('disabled', true)
                      .removeAttr('data-disable-with');"
        end
        format.html do
          redirect_to new_recipient_proposal_path(@recipient)
        end
      else
        format.js
        format.html { render :edit }
      end
    end
  end

  private

    def recipient_params
      params.require(:recipient)
            .permit(:name, :website, :street_address, :country, :charity_number,
                    :company_number, :operating_for, :multi_national, :income,
                    :employees, :volunteers, :org_type, organisation_ids: [])
    end
end
