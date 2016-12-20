class ProposalsController < ApplicationController
  before_action :ensure_logged_in
  before_action :recipient_country, :load_select_options, except: :index
  before_action :load_proposal, only: [:edit, :update]

  def new
    return edit_recipient_proposal_path(@recipient, @proposal) if
                                        @recipient.incomplete_first_proposal?
    return recommended_funds_path if @proposal
    if @recipient.valid? # TODO: without db call?
      @proposal = @recipient.proposals.new(state: 'initial')
      return unless @recipient.created_at < Date.new(2016, 4, 30) # TODO: refactor
      @recipient.transfer_profile_to_new_proposal(@recipient.profiles.last,
                                                  @proposal)
    else
      redirect_to edit_recipient_path(@recipient)
    end
  end

  def create
    @proposal = @recipient.proposals.new(proposal_params)

    respond_to do |format|
      if @proposal.save
        format.js do
          @proposal.next_step!
          render js: "window.location.href = '#{recommended_funds_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
        end
        format.html do
          @proposal.next_step!
          redirect_to recommended_funds_path
        end
      else
        format.js
        format.html { render :new }
      end
    end
  end

  def index
    if @proposal
      @proposals = @recipient.proposals
    else
      redirect_to recommended_funds_path
    end
  end

  def edit
    @recipient.transfer_profile_to_existing_proposal(@recipient.profiles.last,
                                                     @proposal)
    return unless request.referer
    session.delete(:return_to) if request.referer.ends_with?('/proposals')
  end

  def update
    @proposal.state = 'transferred' if @proposal.initial?
    respond_to do |format|
      if @proposal.update_attributes(proposal_params)
        format.js do
          @proposal.next_step! unless @proposal.complete?
          flash[:notice] = 'Funding recommendations updated!'

          if session[:return_to]
            fund = Fund.find_by(slug: session.delete(:return_to))
            render js: "window.location.href = '#{fund_eligibility_path(fund)}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
          else
            render js: "window.location.href = '#{recommended_funds_path}';
                        $('button[type=submit]').prop('disabled', true)
                        .removeAttr('data-disable-with');"
          end
        end
        format.html do
          @proposal.next_step! unless @proposal.complete?
          flash[:notice] = 'Funding recommendations updated!'

          if session[:return_to]
            fund = Fund.find_by(slug: session.delete(:return_to))
            redirect_to fund_eligibility_path(fund)
          else
            redirect_to recommended_funds_path
          end
        end
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
        :affect_other, :gender, :beneficiaries_other,
        :beneficiaries_other_required, :affect_geo, :title, :tagline, :private,
        :outcome1, :implementations_other_required, :implementations_other,
        age_group_ids: [], beneficiary_ids: [], country_ids: [],
        district_ids: [], implementation_ids: []
      )
    end

    def load_proposal
      @proposal = @recipient.proposals.find(params[:id])
    end

    def recipient_country
      # TODO: refactor
      @recipient_country = Country.find_by(alpha2: @recipient.country) ||
                           @recipient.profiles.first.countries.first
      gon.orgCountry = @recipient_country.name
    end

    def district_section(district)
      if district.region.nil?
        district.sub_country.nil? ? 'All regions' : district.sub_country
      else
        "#{district.sub_country}/#{district.region}"
      end
    end

    def load_select_options
      @beneficiaries_people = Beneficiary.order(:sort).where(category: 'People')
      @beneficiaries_other = Beneficiary.order(:sort).where(category: 'Other')
      @district_ids = @recipient_country
                      .districts.order(:region, :district).map do |d|
                        [
                          d.district,
                          d.id,
                          { "data-section": district_section(d) }
                        ]
                      end
    end
end
