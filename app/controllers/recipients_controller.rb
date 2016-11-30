class RecipientsController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient, :ensure_recipient,
                :years_ago, :load_proposal
  before_filter :ensure_proposal_present, except: [:edit, :update]
  before_filter :check_organisation_ownership_or_funder, only: :show
  before_filter :load_funder, only: [:comparison, :eligibility, :update_eligibility, :apply]
  before_filter :load_feedback, except: [:unlock_funder, :vote]
  before_filter :funder_attribute, only: [:comparison, :eligibility, :update_eligibility]

  before_filter :refine_recommendations, except: [:edit, :update]

  def edit
    @recipient.get_charity_data
    @recipient.get_company_data
    redirect_to new_recipient_proposal_path(@recipient) if @recipient.save
  end

  def update
    respond_to do |format|
      if @recipient.update_attributes(recipient_params)
        format.js {
          render :js => "window.location.href = '#{new_recipient_proposal_path(@recipient)}';
                      $('button[type=submit]').prop('disabled', true)
                      .removeAttr('data-disable-with');"
        }
        format.html {
          redirect_to new_recipient_proposal_path(@recipient)
        }
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
    @funds = @recipient.proposals.last.funds.order('recommendations.total_recommendation DESC', 'funds.name')

    render 'recipients/funders/all_funders'
  end

  def dashboard # TODO: refactor
    @search = Funder.ransack(params[:q])
    @profile = @recipient.profiles.where('year = ?', 2015).first
  end

  def show # TODO: refactor
    @recipient = Recipient.find_by_slug(params[:id])
  end

  private

    def refine_recommendations
      @recipient.proposals.last.refine_recommendations
    end

    def load_recipient
      @recipient = Recipient.find_by_slug(params[:id]) || current_user.organisation if logged_in?
    end

    def load_funder
      @funder = Funder.find_by_slug(params[:id])
    end

    def load_feedback
      @feedback = current_user.feedbacks.new if logged_in?
    end

    def years_ago
      if params[:years_ago].present?
        @years_ago = params[:years_ago].to_i
      else
        @years_ago = 1
      end
    end

    def funder_attribute # TODO: refactor
      @funding_stream = params[:funding_stream] || 'All'

      if @funder.attributes.any?
        @year_of_funding = @funder.attributes.where('grant_count > ?', 0).order(year: :desc).first.year
        @funder_attribute = @funder.attributes.where('year = ? AND funding_stream = ?', @year_of_funding, @funding_stream).first
      end
    end

    def eligibility_params # TODO: refactor
      params.require(:recipient).permit(eligibilities_attributes: [:id, :eligible, :restriction_id, :recipient_id])
    end

    def recipient_params
      params.require(:recipient).permit(:name, :website, :street_address,
        :country, :charity_number, :company_number, :operating_for,
        :multi_national, :income, :employees, :volunteers, :org_type,
        organisation_ids: [])
    end

end
