class ProposalsController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient, :prevent_funder_access
  before_filter :ensure_proposal_present, except: [:new, :create, :edit]
  before_filter :load_proposal, only: [:edit, :update]
  before_filter :recipient_country

  def new
    # if @recipient.proposals.count == 1 && @recipient.proposals.last.state != 'complete'
    #   flash[:alert] = 'Please fully complete your first proposal before creating a second.'
    #   redirect_to edit_recipient_proposal_path(@recipient, @recipient.proposals.last)
    # else
      # session[:return_to] ||= params[:return_to]
      gon.orgCountry = @recipient_country.name
      @proposal = @recipient.proposals.new
      @proposal.state = 'initial'
    # end
  end

  def create
    @proposal = @recipient.proposals.new(proposal_params)

    respond_to do |format|
      if @proposal.save
        format.js   {
          @proposal.next_step!
          # if session[:return_to]
          #   flash[:notice] = 'Funding proposal saved'
          #   render :js => "window.location.href = '#{recipient_apply_path(Funder.find_by_slug(session.delete(:return_to)))}';
          #                 $('button[type=submit]').prop('disabled', true)
          #                 .removeAttr('data-disable-with');"
          # else
            flash[:notice] = 'Your funder recommendations have been updated!'
            render :js => "window.location.href = '#{recommended_funders_path}';
                          $('button[type=submit]').prop('disabled', true)
                          .removeAttr('data-disable-with');"
          # end
        }
        format.html {
          @proposal.next_step!
          # if session[:return_to]
          #   flash[:notice] = 'Funding proposal saved'
          #   redirect_to recipient_apply_path(Funder.find_by_slug(session.delete(:return_to)))
          # else
            flash[:notice] = 'Your funder recommendations have been updated!'
            redirect_to recommended_funders_path
          # end
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
    # redirect_to recommended_funders_path unless @recipient.incomplete_proposals?
  end

  def update
    respond_to do |format|
      if @proposal.update_attributes(proposal_params)
        format.js   {
          @proposal.next_step!
          flash[:notice] = 'Funding proposal updated!'
          render :js => "window.location.href = '#{recipient_proposals_path(@recipient)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        }
        format.html {
          @proposal.next_step!
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
    params.require(:proposal).permit(
      :type_of_support, :funding_duration, :funding_type, :total_costs,
      :total_costs_estimated, :all_funding_required, :affect_people,
      :affect_other, :gender, :beneficiaries_other, :beneficiaries_other_required,
      :affect_geo,

      :title,

      age_group_ids: [], beneficiary_ids: [], country_ids: [],
      district_ids: [])
  end

  def load_recipient
    @recipient = current_user.organisation
  end

  def load_proposal
    @proposal = @recipient.proposals.find(params[:id])
  end

  def recipient_country
    # refactor
    @recipient_country = Country.find_by_alpha2(@recipient.country) || @recipient.profiles.first.countries.first
  end

end
