class RecipientsController < ApplicationController
  before_action :ensure_logged_in, :load_recipient, :ensure_recipient,
                :years_ago, :load_proposal
  before_action :ensure_proposal_present, except: [:edit, :update]
  before_action :check_organisation_ownership, only: :show
  before_action :load_funder, only: [:comparison, :eligibility,
                                     :update_eligibility, :apply]
  before_action :load_feedback, except: [:unlock_funder, :vote]

  before_action :refine_recommendations, except: [:edit, :update]

  def edit
    @recipient.scrape_charity_data
    @recipient.scrape_company_data
    redirect_to new_recipient_proposal_path(@recipient) if @recipient.save
  end

  def update
    respond_to do |format|
      if @recipient.update_attributes(recipient_params)
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

  def recommended_funds
    @funds = @recipient.recommended_with_eligible_funds

    render 'recipients/funders/recommended_funders'
  end

  def eligible_funds
    @funds = @recipient.eligible_funds

    render 'recipients/funders/eligible_funders'
  end

  def ineligible_funds
    @funds = @recipient.ineligible_funds

    render 'recipients/funders/ineligible_funders'
  end

  def all_funds
    @funds = @recipient.proposals.last
                       .funds
                       .includes(:funder)
                       .order('recommendations.total_recommendation DESC',
                              'funds.name')

    render 'recipients/funders/all_funders'
  end

  def dashboard # TODO: refactor
    @search = Funder.ransack(params[:q])
    @profile = @recipient.profiles.where('year = ?', 2015).first
  end

  def show # TODO: refactor
    @recipient = Recipient.find_by(slug: params[:id])
  end

  private

    def refine_recommendations
      @recipient.proposals.last.refine_recommendations
    end

    def load_recipient
      return unless logged_in?
      @recipient = Recipient.find_by(slug: params[:id]) ||
                   current_user.organisation
    end

    def load_funder
      @funder = Funder.find_by(slug: params[:id])
    end

    def load_feedback
      @feedback = current_user.feedbacks.new if logged_in?
    end

    def years_ago
      @years_ago = if params[:years_ago].present?
                     params[:years_ago].to_i
                   else
                     1
                   end
    end

    def recipient_params
      params.require(:recipient)
            .permit(:name, :website, :street_address, :country, :charity_number,
                    :company_number, :operating_for, :multi_national, :income,
                    :employees, :volunteers, :org_type, organisation_ids: [])
    end
end
