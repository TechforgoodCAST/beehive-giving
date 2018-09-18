class ProposalsController < ApplicationController
  layout 'fullscreen'

  # TODO: refactor helper?
  before_action :load_collection

  before_action :ensure_collection # TODO: refactor

  def new
    @recipient = Recipient.find_by_hashid(params[:hashid])

    return redirect_to root_path if @recipient.proposal # TODO: refactor

    @proposal = @recipient.build_proposal
    @proposal.user = current_user || User.new

    @proposal.answers = criteria.map do |c|
      Answer.new(category: @proposal, criterion: c)
    end
  end

  def create
    @recipient = Recipient.find_by_hashid(params[:hashid])

    return redirect_to root_path if @recipient.proposal # TODO: refactor

    @proposal = @recipient.build_proposal(form_params)
    @proposal.collection = @collection

    if @proposal.save
      redirect_to new_charge_path(@proposal)
    else
      @districts = District.where(country_id: form_params[:country])
      render :new
    end
  end

  private

    def criteria
      @collection.criteria.where(category: 'Proposal')
                 .where('type = ? OR type = ?', 'Restriction', 'Priority')
    end

    def ensure_collection
      return if @collection
      redirect_back(fallback_location: root_path)
    end

    def form_params
      params.require(:proposal).permit(
        :category_code, :country_id, :description, :geographic_scale, :max_amount,
        :max_duration, :min_amount, :min_duration, :public_consent,
        :support_details, :title, country_ids: [], district_ids: [],
        theme_ids: [], answers_attributes: %i[eligible criterion_id],
        user_attributes: %i[
          email email_confirmation first_name last_name marketing_consent
          terms_agreed
        ]
      )
    end

    def load_collection
      # TODO: .includes(funds: :questions)
      @collection = Funder.find_by(slug: params[:slug]) ||
                    Theme.find_by(slug: params[:slug])
    end
end
