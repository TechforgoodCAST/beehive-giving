class ProposalsController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient
  before_filter :load_proposal, only: [:edit, :update]

  def new
    if @recipient.proposals.count > 0
      flash[:alert] = 'Sorry, you can only create one funding proposal at the moment'
      redirect_to recipient_proposals_path(@recipient)
    else
      session[:return_to] ||= params[:return_to]
      @proposal = @recipient.proposals.new
    end
  end

  def create
    @proposal = @recipient.proposals.new(proposal_params)

    respond_to do |format|
      if @proposal.save
        format.js   {
          if session[:return_to]
            flash[:notice] = 'Funding proposal saved'
            render :js => "window.location.href = '#{recipient_apply_path(Funder.find_by_slug(session.delete(:return_to)))}';
                          $('button[type=submit]').prop('disabled', true)
                          .removeAttr('data-disable-with');"
          else
            flash[:notice] = 'Your funder recommendations have been updated!'
            render :js => "window.location.href = '#{recommended_funders_path}';
                          $('button[type=submit]').prop('disabled', true)
                          .removeAttr('data-disable-with');"
          end
        }
        format.html {
          if session[:return_to]
            flash[:notice] = 'Funding proposal saved'
            redirect_to recipient_apply_path(Funder.find_by_slug(session.delete(:return_to)))
          else
            flash[:notice] = 'Your funder recommendations have been updated!'
            redirect_to recommended_funders_path
          end
        }
      else
        format.js
        format.html { render :new }
      end
    end
  end

  def index
    if @recipient.has_proposal?
      @proposals = @recipient.proposals
    else
      redirect_to recommended_funders_path
    end
  end

  def edit
    redirect_to recommended_funders_path unless @recipient.has_proposal?
  end

  def update
    respond_to do |format|
      if @proposal.update_attributes(proposal_params)
        format.js   {
          flash[:notice] = 'Funding proposal updated!'
          render :js => "window.location.href = '#{recipient_proposals_path(@recipient)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        }
        format.html {
          flash[:notice] = 'Funding proposal updated!'
          redirect_to recipient_proposals_path(@recipient)
        }
      else
        format.js
        format.html { render :edit }
      end
    end
  end

  private

  def proposal_params
    params.require(:proposal).permit(:title, :tagline, :gender, :min_age,
      :max_age, :beneficiaries_count, :funding_duration, :activity_costs,
      :people_costs, :capital_costs, :other_costs, :total_costs,
      :activity_costs_estimated, :people_costs_estimated,
      :capital_costs_estimated, :other_costs_estimated, :all_funding_required,
      :outcome1, :outcome2, :outcome3, :outcome4, :outcome5, :beneficiaries_other,
      :beneficiaries_other_required, beneficiary_ids: [],
      country_ids: [],district_ids: [])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

  def load_proposal
    @proposal = @recipient.proposals.find(params[:id])
  end

end
