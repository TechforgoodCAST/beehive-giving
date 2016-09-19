class ProposalsController < ApplicationController

  before_filter :ensure_logged_in, :load_recipient,
                :prevent_funder_access, :recipient_country
  before_filter :load_proposal, only: [:edit, :update]

  def new
    if @recipient.incomplete_first_proposal?
      redirect_to edit_recipient_proposal_path(@recipient, @recipient.proposals.last)
    elsif @recipient.has_proposal?
      redirect_to recommended_funds_path
    else
      if @recipient.valid?
        @proposal = @recipient.proposals.new(state: 'initial')
        @recipient.transfer_profile_to_new_proposal(@recipient.profiles.last, @proposal)
      else
        redirect_to edit_recipient_path(@recipient)
      end
    end
  end

  def create
    @proposal = @recipient.proposals.new(proposal_params)

    respond_to do |format|
      if @proposal.save
        format.js   {
          @proposal.next_step!
          render :js => "window.location.href = '#{recommended_funds_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        }
        format.html {
          @proposal.next_step!
          redirect_to recommended_funds_path
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
      redirect_to recommended_funds_path
    end
  end

  def edit
    @recipient.transfer_profile_to_existing_proposal(@recipient.profiles.last, @proposal)
    if request.referer
      session.delete(:return_to) if request.referer.ends_with?('/proposals')
    end
  end

  def update
    @proposal.state = 'transferred' if @proposal.initial?
    respond_to do |format|
      if @proposal.update_attributes(proposal_params)
        format.js   {
          @proposal.next_step! unless @proposal.complete?
          flash[:notice] = 'Funding recommendations updated!'

          if session[:return_to]
            fund = Fund.find_by_slug(session.delete(:return_to))
            render :js => "window.location.href = '#{fund_eligibility_path(fund)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
          else
            render :js => "window.location.href = '#{recommended_funds_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
          end
        }
        format.html {
          @proposal.next_step! unless @proposal.complete?
          flash[:notice] = 'Funding recommendations updated!'

          if session[:return_to]
            fund = Fund.find_by_slug(session.delete(:return_to))
            redirect_to fund_eligibility_path(fund)
          else
            redirect_to recommended_funds_path
          end
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
      :affect_geo, :title, :tagline, :private, :outcome1,
      :implementations_other_required, :implementations_other,
      age_group_ids: [], beneficiary_ids: [], country_ids: [],
      district_ids: [], implementation_ids: [])
  end

  def load_proposal
    @proposal = @recipient.proposals.find(params[:id])
  end

  def recipient_country
    # refactor
    @recipient_country = Country.find_by_alpha2(@recipient.country) || @recipient.profiles.first.countries.first
    gon.orgCountry = @recipient_country.name
  end

end
